defmodule Judgement.GameService do
    alias Judgement.Repo
    alias Judgement.Player
    alias Judgement.Rating
    alias Judgement.Result
    alias Judgement.ResultRepo

    def create_player(name, email) do
       result = %Player{name: name, email: email, rating: %Rating{}}
                          |> Repo.insert
       case result do
        {:ok, player} -> player
        {:error, _player} -> raise "problems creating a player" 
       end
    end

    def find_player(email) do
      Repo.get_by(Player, email: email)
      |> Repo.preload(:rating)
    end

    def create_result(winner, loser) do
      winner_rating = Rating |> Repo.get(winner.rating.id)
      winner_rating_before = winner_rating.value
      loser_rating = Rating |> Repo.get(loser.rating.id)      
      loser_rating_before = loser_rating.value
      {winner_rating_after, loser_rating_after} = Elo.rate(winner_rating_before, loser_rating_before, :win, k_factor: 15, round: :down)
      %Result{winner: winner, 
              loser: loser,
              winner_rating_before: winner_rating_before,
              winner_rating_after: winner_rating_after,
              loser_rating_before: loser_rating_before,
              loser_rating_after: loser_rating_after}
              |> Repo.insert

      Ecto.Changeset.change(winner.rating, %{value: winner_rating_after})
        |> Repo.update

      Ecto.Changeset.change(loser.rating, %{value: loser_rating_after})
        |> Repo.update
    end

    def leaderboard() do
      Player
        |> Repo.all
        |> Repo.preload(:rating)
        |> Enum.with_index(1)
        |> Enum.map(fn {p, index} -> %{rank: index, 
                                      points: p.rating.value, 
                                      name: p.name,
                                      wins: Player.wins(p),
                                      losses: Player.losses(p),
                                      ratio: Player.ratio(p)} end)
    end

    def h2h(player1, player2) do
      
    end


  end
  