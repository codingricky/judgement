defmodule Judgement.GameServiceTest do
    use ExUnit.Case

    alias Judgement.Repo
    alias Judgement.GameService

    setup do
        :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
    end

    test "create a player" do
        player = GameService.create_player("john", "john@example.com")
        refute nil == player    
    end

    test "create a rating" do
        player = GameService.create_player("john", "john@example.com")
        saved_player = GameService.find_player(player.email)
        refute nil == saved_player
        refute nil == saved_player.rating
        assert 1000 == saved_player.rating.value
    end

    test "create a result" do
        winner = GameService.create_player("john", "john@example.com")
        loser = GameService.create_player("joe", "joe@example.com")

        GameService.create_result(winner, loser)

        saved_winner = GameService.find_player(winner.email)
        assert 1007 == saved_winner.rating.value

        saved_loser = GameService.find_player(loser.email)
        assert 992 == saved_loser.rating.value
    end

    def create_result(winner, loser, times) do
        if (times > 0) do
            GameService.create_result(winner, loser)
            create_result(winner, loser, times - 1)            
        end
    end

    test "leaderboard returns the correct results" do
        winner = GameService.create_player("john", "john@example.com")
        loser = GameService.create_player("joe", "joe@example.com")

        create_result(winner, loser, 10)

        leaderboard = GameService.leaderboard()
        assert 2 == length(leaderboard)
        [first, second] = leaderboard
        assert 1 == first[:rank]
        assert 1058 == first[:points]
    end
end