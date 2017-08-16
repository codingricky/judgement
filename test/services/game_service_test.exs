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

    test "creates a rating" do
        player = GameService.create_player("john", "john@example.com")
        saved_player = GameService.find(player.email)
        refute nil == saved_player
        refute nil == saved_player.rating
        assert 1000 == saved_player.rating.value
    end

end