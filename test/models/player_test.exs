defmodule Judgement.PlayerTest do
  use ExUnit.Case
  
  alias Judgement.Player
  alias Judgement.Result
  alias Judgement.Repo
  alias Judgement.GameService

  @winner_email "john-hello@example.com"
  @loser_email "joe-blogs@example.com"

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
    
    {:ok, winner} = GameService.create_player("john", @winner_email)
    {:ok, loser} = GameService.create_player("joe", @loser_email)
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

  test "h2h" do
    winner = Player.find(@winner_email)
    loser = Player.find(@loser_email)
    create_result(9)
    GameService.create_result(loser, winner)
    
    h2h = Player.h2h(winner, loser)
    assert 10 == h2h[:wins]
    assert 1 == h2h[:losses]     
  end

  test "is active requires at least 10 games" do
    winner = Player.find(@winner_email)
    loser = Player.find(@loser_email)    
    
    assert false == Player.is_active?(winner)
    create_result(9)

    assert true == Player.is_active?(winner)
    assert true == Player.is_active?(loser)    
  end

  test "is active doesn't count if games are too old" do
    winner = Player.find(@winner_email) 
    loser = Player.find(@loser_email)    
    create_result(9)
    
    day_in_seconds = 60 * 60 * 24
    twenty_one_days_ago = NaiveDateTime.utc_now
                  |> NaiveDateTime.add(day_in_seconds * 21 * -1, :second)
    Repo.update_all(Result, [set: [inserted_at: twenty_one_days_ago]])
    assert false == Player.is_active?(winner)
    assert false == Player.is_active?(loser)    
  end
end
