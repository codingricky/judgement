require IEx

defmodule SlackRtm do
  use Slack

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

  def handle_connect(_slack, state) do
    IO.puts "connected"
    {:ok, state}
  end

  def handle_event(message = %{type: "message"}, slack, state) do
    cond do 
        regex? message.text, @h2h_txt -> h2h(message, slack)
        regex? message.text, @defeated_txt -> defeated(message, slack)
        regex? message.text, @lookup_txt -> lookup(message, slack)
        regex? message.text, @mine_txt -> mine(message, slack)
        regex? message.text, @change_colours_txt -> change_colour(message, slack)
        regex? message.text, ~r/help/ -> help(message, slack)
        regex? message.text, ~r/^show$/ -> show(message, slack)
        regex? message.text, ~r/show full/ -> show_full(message, slack)
        regex? message.text, ~r/(^reverse show$)|(^woes$)/ -> reverse_show(message, slack)
        true -> store_quote(message, slack)
    end
    {:ok, state}
  end

  def handle_event(_, _, state), do: {:ok, state}

  defp regex?(string, expression) do
    String.match?(string, expression)
  end

  defp help(message, slack) do
    send_message(@help_message, message.channel, slack)
  end

  defp show_full(message, slack) do
    send_message(SlackService.show_full, message.channel, slack)
  end

  defp show(message, slack) do
    send_message(SlackService.show, message.channel, slack)
  end

  defp reverse_show(message, slack) do
    send_message(SlackService.reverse_show, message.channel, slack)
  end

  defp lookup(message, _slack) do
    case Regex.named_captures(@lookup_txt, message.text) do
      %{"player" => player} -> SlackService.lookup(player, message.channel)
      _ -> ""
    end  
  end

  defp defeated(message, _slack) do
    case Regex.named_captures(@defeated_txt, message.text) do
      %{"winner" => winner, "loser" => loser, "times" => ""} -> SlackService.create_result(winner, loser)
      %{"winner" => winner, "loser" => loser, "times" => times} -> SlackService.create_result(winner, loser, String.to_integer(times))
      _ -> ""
    end
  end

  defp h2h(message, slack) do 
    case Regex.named_captures(@h2h_txt, message.text) do
      %{"player_1" => player_1, "player_2" => player_2} -> send_message(SlackService.h2h(player_1, player_2), message.channel, slack)
      _ -> ""
    end
  end

  defp mine(message, slack) do
    case Regex.named_captures(@mine_txt, message.text) do
      %{"player" => player} -> send_message(SlackService.who_does_this_player_mine(player), message.channel, slack)
      _ -> ""
    end
  end

  defp change_colour(message, slack) do
    case Regex.named_captures(@change_colours_txt, message.text) do
      %{"player" => player, "colour" => colour} -> send_message(SlackService.change_colour(player, colour), message.channel, slack)
      _ -> ""
    end
  end

  def store_quote(_message, _slack) do
    
  end

  def handle_info({:message, _text, _channel}, _slack, state) do
    {:ok, state}
  end
  def handle_info(_, _, state), do: {:ok, state}
end