defmodule Judgement.GameService do
    alias Judgement.Repo
    alias Judgement.Player
    alias Judgement.Rating
    alias Judgement.Result

    def create_player(name, email) do
       result = %Player{name: name, email: email, rating: %Rating{}}
                          |> Repo.insert
       case result do
        {:ok, player} -> player
        {:error, player} -> raise "problems creating a player" 
       end
    end

    def find(email) do
      Repo.get_by(Player, email: email)
      |> Repo.preload :rating
    end

    def create_result(winner, loser) do
      winner_rating_before = winner.rating.value
      loser_rating_before = loser.rating.value
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


  end
  