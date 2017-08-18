defmodule Judgement.PlayerTest do
  use ExUnit.Case
  
  alias Judgement.Player
  alias Judgement.Repo
  alias Judgement.GameService

  @winner_email "john-hello@example.com"
  @loser_email "joe-blogs@example.com"

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
    
    winner = GameService.create_player("john", @winner_email)
    loser = GameService.create_player("joe", @loser_email)
    GameService.create_result(winner, loser)
    :ok
  end

  def create_result(times) do
    winner = Player.find(@winner_email)
    loser = Player.find(@loser_email)

    if (times > 0) do
        GameService.create_result(winner, loser)
        create_result(times - 1)            
    end
  end
  
  test "win" do
    winner = Player.find(@winner_email)
    assert 1 == Player.wins(winner)
  end

  test "losses" do
    winner = Player.find(@winner_email)
    assert 0 == Player.losses(winner)
  end

  test "ratio" do
    winner = Player.find(@winner_email)
    assert 100 == Player.ratio(winner)
  end

  test "streak with all wins" do
    winner = Player.find(@winner_email)    
    create_result(50)

    assert 51 == Player.streak(winner)
  end

  test "streak with win broken by a loss" do
    winner = Player.find(@winner_email)
    loser = Player.find(@loser_email)  
    create_result(10)
    GameService.create_result(loser, winner)

    assert 0 == Player.streak(winner)
  end

  test "streak with win broken by a loss, then a win" do
    winner = Player.find(@winner_email)
    loser = Player.find(@loser_email)  
    create_result(10)
    GameService.create_result(loser, winner)
    create_result(2)
    
    assert 2 == Player.streak(winner)
  end
end
