require IEx

defmodule SlackRtm do
  use Slack
  require Logger

  alias Judgement.SlackService

  @help_message """
                *show*                                    shows the leaderboard
            *show full*                                    shows the full leaderboard
            *reverse show*                            shows the leaderboard in reverse
            *[winner] defeats [loser] n [times]*           creates a result
            *[winner] h2h [loser]*                         shows the h2h record between two players
            *lookup [player]*                              looks up a player
            *who does [player] mine?*                      see which player does this player mine the most
            *what's the best day to play [player]?*        tells you the best day to play a player to maximise your chances
            *change [player]'s colour to [new colour]*     change a player's colour
            *help*                                         this message
    """

  @defeated_txt ~r/(?<winner>[A-Za-z]+) b (?<loser>[A-Za-z]+)( )?(?<times>[1-5])?/
  @h2h_txt ~r/(?<player_1>[A-Za-z]+) h2h (?<player_2>[A-Za-z]+)/
  @lookup_txt ~r/lookup (?<player>[A-Za-z]+)/
  @mine_txt ~r/who does (?<player>[A-Za-z]+) mine/
  @change_colours_txt ~r/change (?<player>[A-Za-z]+)'s colour to (?<colour>[A-Za-z]+)/
  @best_day_to_play_txt ~r/what's the best day to play (?<player>[A-Za-z]+)?/
  @what_would_player_say_txt ~r/(w|W)hat would (?<player>[A-Za-z]+)? say/

  def handle_connect(_slack, state) do
    Logger.info "connected"
    {:ok, state}
  end

  def handle_event(message = %{type: "message"}, slack, state) do
    user = message[:user]
    Logger.info "#{inspect(message)} from #{inspect(slack.me[:name])}"
    is_bot = is_bot(user)
    Logger.info "#{inspect(user)} is_bot=#{inspect(is_bot)}"
    case is_bot(user) do 
      true -> nil
      false -> handle_message(message, slack)
    end

    {:ok, state}
  end

  def is_bot(user) do
    if user == nil do 
        true
    else
      case Slack.Web.Users.info(user) do
        %{"user" => %{"is_bot" => is_bot}} -> is_bot
        _ -> true
      end 
    end
  end

  def handle_event(_, _, state), do: {:ok, state}

  defp handle_message(message, slack) do
     try do
      cond do 
          regex? message.text, @h2h_txt -> h2h(message, slack)
          regex? message.text, @defeated_txt -> defeated(message, slack)
          regex? message.text, @lookup_txt -> lookup(message, slack)
          regex? message.text, @mine_txt -> mine(message, slack)
          regex? message.text, @change_colours_txt -> change_colour(message, slack)
          regex? message.text, @best_day_to_play_txt -> best_day_to_play(message, slack)
          regex? message.text, @what_would_player_say_txt -> what_would_player_say(message, slack)          
          regex? message.text, ~r/(^reverse show$)|(^woes$)/ -> reverse_show(message, slack)          
          regex? message.text, ~r/help/ -> help(message, slack)
          regex? message.text, ~r/^show$/ -> show(message, slack)
          regex? message.text, ~r/show full/ -> show_full(message, slack)
          regex? message.text, ~r/(^reverse show$)|(^woes$)/ -> reverse_show(message, slack)
          true -> store_quote(message, slack)
      end
    catch
      e -> Logger.error("Error occurred #{inspect(e)} #{inspect(Process.info(self(), :current_stacktrace))}")      
    rescue
      e -> Logger.error("Error occurred #{inspect(e)} #{inspect(Process.info(self(), :current_stacktrace))}") 
    end
  end

  defp regex?(string, expression) do
    String.match?(string, expression)
  end

  defp help(message, slack) do
    Logger.info("help")
    SlackClient.send_message(@help_message, message.channel, slack)
  end

  defp show_full(message, slack) do
    Logger.info("show full")
    SlackClient.send_message(SlackService.show_full, message.channel, slack)
  end

  defp show(message, slack) do
    Logger.info("show")
    SlackClient.send_message(SlackService.show, message.channel, slack)
  end

  defp reverse_show(message, slack) do
    Logger.info("reverse show")
    SlackClient.send_message(SlackService.reverse_show, message.channel, slack)
  end

  defp lookup(message, slack) do
    Logger.info("lookup")
    case Regex.named_captures(@lookup_txt, message.text) do
      %{"player" => player} -> SlackService.lookup(player, message.channel, slack)
      _ -> ""
    end  
  end

  defp defeated(message, slack) do
    Logger.info("defeated")
    result = case Regex.named_captures(@defeated_txt, message.text) do
      %{"winner" => winner, "loser" => loser, "times" => ""} -> SlackService.create_result(winner, loser)
      %{"winner" => winner, "loser" => loser, "times" => times} -> SlackService.create_result(winner, loser, String.to_integer(times))
      _ -> {:ok}
    end

    case result do
      {:ok} -> {:ok}
      {:error, error} -> SlackClient.send_message(error, message.channel, slack) 
    end
  end

  defp h2h(message, slack) do 
    Logger.info("h2h")
    case Regex.named_captures(@h2h_txt, message.text) do
      %{"player_1" => player_1, "player_2" => player_2} -> SlackClient.send_message(SlackService.h2h(player_1, player_2), message.channel, slack)
      _ -> ""
    end
  end

  defp mine(message, slack) do
    Logger.info("mine")
    case Regex.named_captures(@mine_txt, message.text) do
      %{"player" => player} -> SlackClient.send_message(SlackService.who_does_this_player_mine(player), message.channel, slack)
      _ -> ""
    end
  end

  defp change_colour(message, slack) do
    Logger.info("change colour")
    case Regex.named_captures(@change_colours_txt, message.text) do
      %{"player" => player, "colour" => colour} -> SlackClient.send_message(SlackService.change_colour(player, colour), message.channel, slack)
      _ -> ""
    end
  end

  defp best_day_to_play(message, slack) do
    Logger.info("best day")
    case Regex.named_captures(@best_day_to_play_txt, message.text) do
      %{"player" => player} -> SlackClient.send_message("The best day to play #{player} is #{SlackService.best_day_to_play(player)}", message.channel, slack)
      _ -> ""
    end
  end

  def store_quote(message, _slack) do
    Logger.info "storing message=#{inspect(message)}"
    if message.user do
      SlackService.store_quote(message.text, message.user)      
    end
  end

  defp what_would_player_say(message, slack) do
    Logger.info "what would player say"
    case Regex.named_captures(@what_would_player_say_txt, message.text) do
      %{"player" => player} -> SlackService.what_would_player_say(player, message.channel, slack)
      _ -> ""
    end      
  end

  def handle_info({:message, _text, _channel}, _slack, state) do
    {:ok, state}
  end
  def handle_info(_, _, state), do: {:ok, state}
end