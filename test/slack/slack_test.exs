defmodule Judgement.SlackTest do
    use ExUnit.Case, async: false

    alias Judgement.Repo
    alias Judgement.GameService
    
    import Mock

    @channel "testing"

    setup do
        :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
    end

    test "help" do
        with_mock(MockSlackClient, [is_bot: fn(_user) -> false end,
                                send_message: fn(_channel, _message, _slack) -> nil end,
                                post_message: fn(_channel, _message, _attachments) -> nil end]) do
            slack = %Slack.State{me: %{name: "Homer"}}
            SlackRtm.handle_event(message("help"), slack, nil)
        end
    end

    test "show" do
        GameService.create_player("winner", "winner@example.com")
        GameService.create_player("loser", "loser@example.com")
        winner = GameService.find_player("winner@example.com")
        loser = GameService.find_player("loser@example.com")        
        # need 10 games for it to count
        GameService.create_result(winner, loser, 5, false)
        GameService.create_result(winner, loser, 5, false)

        expected_show = "1. *winner*  _10-0_ `1058 points` _100% 10_\n2. *loser*  _0-10_ `932 points` _0% 0_"
        
        with_mock(MockSlackClient, [is_bot: fn(_user) -> false end,
                                send_message: fn(channel, message, slack) -> IO.puts("#{inspect(channel)} #{inspect(message)} #{inspect(slack)}") end,
                                post_message: fn(_channel, _message, _attachments) -> nil end]) do
            slack = %Slack.State{me: %{name: "Homer"}}
            SlackRtm.handle_event(message("show"), slack, nil)
            assert called MockSlackClient.send_message(@channel, expected_show, slack)
        end 
    end

    defp message(message) do
        %{type: "message", text: message, channel: @channel}        
    end
end