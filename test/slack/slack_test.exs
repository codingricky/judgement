defmodule Judgement.SlackTest do
    use ExUnit.Case, async: false
    import Mock
    require Logger

    alias Judgement.Repo
    alias Judgement.GameService
    alias Judgement.Player
    
    @channel "testing"
    @winner "winner@example.com"
    @loser "loser@example.com"
    @expected_show "1. *winner*  _10-0_ `1058 points` _100% 10_\n2. *loser*  _0-10_ `932 points` _0% 0_"
    

    setup_with_mocks([
        {MockSlackClient, [],
        [is_bot: fn(_user) -> false end,
        send_message: fn(channel, message, _slack) -> Logger.info("sending message #{inspect(message)} to #{inspect(channel)}") end,
        post_message: fn(channel, message, _attachments) -> Logger.info("posting message #{inspect(message)} to #{inspect(channel)}")  end,
        get_name_from_slack_id: fn(slack_id) -> @winner end,
        get_avatar_url_from_slack_id: fn(slack_id) -> "http://example.com" end]},
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
        SlackRtm.handle_event(message("show"), slack, nil)
        assert called MockSlackClient.send_message(@channel, @expected_show, slack)
    end

    test "show full", %{slack: slack} do
        SlackRtm.handle_event(message("show full"), slack, nil)
        assert called MockSlackClient.send_message(@channel, @expected_show, slack)
    end

    test "create result", %{slack: slack} do
        SlackRtm.handle_event(message("winner b loser"), slack, nil)
        assert 11 == Player.wins(Player.find(@winner))
    end

    test "h2h", %{slack: slack} do
        expected_h2h = "*winner* h2h *loser* 10 wins 0 losses 100%"
        SlackRtm.handle_event(message("winner h2h loser"), slack, nil)
        assert called MockSlackClient.send_message(@channel, expected_h2h, slack)        
    end

    # test "what if I played player", %{slack: slack} do
    #     SlackRtm.handle_event(message("what if I played loser?"), slack, nil)
    #     assert called MockSlackClient.send_message(@channel, @expected_show, slack)                
    # end

    defp message(message) do
        %{type: "message", text: message, channel: @channel}        
    end
end