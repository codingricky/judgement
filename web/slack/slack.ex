require IEx

defmodule SlackRtm do
  use Slack

  alias Judgement.SlackService

  @help_message """
                *show*                                    shows the leaderboard
            *show colours*                            shows the the colours
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

  def handle_connect(slack, state) do
    {:ok, state}
  end

  def handle_event(message = %{type: "message"}, slack, state) do
    cond do 
        regex? message.text, ~r/help/ -> help(message, slack)
        regex? message.text, ~r/show/ -> show(message, slack)
        Else -> store_quote(message, slack)
    end
    {:ok, state}
  end
  def handle_event(_, _, state), do: {:ok, state}

  def regex?(string, expression) do
    String.match?(string, expression)
  end

  def help(message, slack) do
    send_message(@help_message, message.channel, slack)
  end

  def show(message, slack) do
    send_message(SlackService.show, message.channel, slack)
  end

  def store_quote(message, slack) do
    
  end

  def handle_info({:message, _text, _channel}, _slack, state) do
    {:ok, state}
  end
  def handle_info(_, _, state), do: {:ok, state}
end