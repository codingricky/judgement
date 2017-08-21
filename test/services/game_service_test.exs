defmodule Judgement.GameServiceTest do
    use ExUnit.Case

    alias Judgement.Repo
    alias Judgement.GameService
    alias Judgement.Result

    setup do
        :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
    end

    test "create a player" do
        {:ok, player} = GameService.create_player("john", "john@example.com")
        refute nil == player    
    end

    test "create a rating" do
        {:ok, player} = GameService.create_player("john", "john@example.com")        
        saved_player = GameService.find_player(player.email)
        refute nil == saved_player
        refute nil == saved_player.rating
        assert 1000 == saved_player.rating.value
    end

    test "create a player with a duplicate email should fail" do
        GameService.create_player("john", "john@example.com")
        {:error, _} = GameService.create_player("some other thing", "john@example.com")
    end

    test "create a player with a duplicate name should fail" do
        GameService.create_player("john", "john@example.com")
        {:error, _} = GameService.create_player("john", "bozo@bozo.com")
    end

    test "create a result" do
        {:ok, winner} = GameService.create_player("john", "john@example.com")
        {:ok, loser} = GameService.create_player("joe", "joe@example.com")

        GameService.create_result(winner, loser)

        saved_winner = GameService.find_player(winner.email)
        assert 1007 == saved_winner.rating.value

        saved_loser = GameService.find_player(loser.email)
        assert 992 == saved_loser.rating.value
    end

    test "create multiple times" do 
        {:ok, winner} = GameService.create_player("john", "john@example.com")
        {:ok, loser} = GameService.create_player("joe", "joe@example.com")

        GameService.create_result(winner, loser, 5)
        # TODO update asserts

        # saved_winner = GameService.find_player(winner.email)
        # assert 1038 == saved_winner.rating.value

        # saved_loser = GameService.find_player(loser.email)
        # assert 956 == saved_loser.rating.value
    end

    test "undos the last result" do
        {:ok, winner} = GameService.create_player("john", "john@example.com")
        {:ok, loser} = GameService.create_player("joe", "joe@example.com")

        GameService.create_result(winner, loser)
        GameService.undo_last_result()

        saved_winner = GameService.find_player(winner.email)
        assert 1000 == saved_winner.rating.value

        saved_loser = GameService.find_player(loser.email)
        assert 1000 == saved_loser.rating.value

        assert 0 == length(Result.all)
    end

    test "undos the last result multiple times" do
        {:ok, winner} = GameService.create_player("john", "john@example.com")
        {:ok, loser} = GameService.create_player("joe", "joe@example.com")

        create_result(winner, loser, 2)
        GameService.undo_last_result()
        GameService.undo_last_result()
        
        saved_winner = GameService.find_player(winner.email)
        assert 1000 == saved_winner.rating.value

        saved_loser = GameService.find_player(loser.email)
        assert 1000 == saved_loser.rating.value

        assert 0 == length(Result.all) 
    end

    def create_result(winner, loser, times) do
        if (times > 0) do
            GameService.create_result(winner, loser)
            create_result(winner, loser, times - 1)            
        end
    end

    test "leaderboard returns the correct results" do
        {:ok, winner} = GameService.create_player("john", "john@example.com")
        {:ok, loser} = GameService.create_player("joe", "joe@example.com")

        create_result(winner, loser, 10)

        leaderboard = GameService.leaderboard()
        assert 2 == length(leaderboard)
        [first, second] = leaderboard

        assert 1 == first[:rank]
        assert 1058 == first[:points]
        assert "john" == first[:name]
        assert 10 == first[:wins]
        assert 0 == first[:losses]
        assert 100 == first[:ratio]
        assert 10 == first[:streak]

        assert 2 == second[:rank]
        assert 932 == second[:points]
        assert "joe" == second[:name]
        assert 0 == second[:wins]
        assert 10 == second[:losses]
        assert 0 == second[:ratio]
        assert 0 == second[:streak]
    end
end