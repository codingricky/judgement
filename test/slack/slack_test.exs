defmodule Judgement.SlackTest do
    use ExUnit.Case, async: false
    import Mock
    require Logger

    alias Judgement.Repo
    alias Judgement.GameService
    
    @channel "testing"
    @winner "winner@example.com"
    @loser "loser@example.com"

    setup_with_mocks([
        {MockSlackClient, [],
        [is_bot: fn(_user) -> false end,
        send_message: fn(channel, message, _slack) -> Logger.info("sending message #{inspect(message)} to #{inspect(channel)}") end,
        post_message: fn(channel, message, _attachments) -> Logger.info("posting message #{inspect(message)} to #{inspect(channel)}")  end]}
    ]) do
        Ecto.Adapters.SQL.Sandbox.checkout(Repo)
        
        GameService.create_player("winner", @winner)
        GameService.create_player("loser", @loser)
        winner = GameService.find_player(@winner)
        loser = GameService.find_player(@loser)        
        # need 10 games for it to count
        GameService.create_result(winner, loser, 5, false)
        GameService.create_result(winner, loser, 5, false)
        slack = %Slack.State{me: %{name: "Homer"}}
        
        {:ok, slack: slack}
    end

    test "help", %{slack: slack} do
        SlackRtm.handle_event(message("help"), slack, nil)
    end

    test "show", %{slack: slack} do
        expected_show = "1. *winner*  _10-0_ `1058 points` _100% 10_\n2. *loser*  _0-10_ `932 points` _0% 0_"
        SlackRtm.handle_event(message("show"), slack, nil)
        assert called MockSlackClient.send_message(@channel, expected_show, slack)
    end

    defp message(message) do
        %{type: "message", text: message, channel: @channel}        
    end
end