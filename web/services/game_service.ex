defmodule Judgement.GameService do
    alias Judgement.Repo
    alias Judgement.Player
    alias Judgement.Rating
    alias Judgement.Result
    alias Judgement.ResultRepo

    def create_player(name, email) do
       Player.changeset(%Player{}, %{name: name, email: email, rating: %{}})
                          |> Repo.insert
    end

    def update_player(name, email) do
      Player.changeset(%Player{}, %{name: name, email: email})
                         |> Repo.update
     end

    def find_player(email) do
      Repo.get_by(Player, email: email)
      |> Repo.preload(:rating)
    end

    def create_result(winner, loser, times) do
      if (times > 0) do 
        create_result(winner, loser)        
        create_result(winner, loser, times - 1) 
      end
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

    def undo_last_result() do
      [first | _] = Result.all_sorted_by_creation_date
      winner_rating_before = first.winner_rating_before
      loser_rating_before = first.loser_rating_before

      winner = Player |> Repo.get(first.winner_id) |> Repo.preload(:rating)
      loser = Player |> Repo.get(first.loser_id) |> Repo.preload(:rating)
      
      Ecto.Changeset.change(winner.rating, %{value: winner_rating_before})
        |> Repo.update

      Ecto.Changeset.change(loser.rating, %{value: loser_rating_before})
        |> Repo.update

      Repo.delete(first)
    end

    def leaderboard() do
      Player
        |> Repo.all
        |> Repo.preload(:rating)
        |> Enum.with_index(1)
        |> Enum.map(fn {p, index} -> %{rank: index, 
                                      player_id: p.id,
                                      points: p.rating.value, 
                                      name: p.name,
                                      wins: Player.wins(p),
                                      losses: Player.losses(p),
                                      total: Player.wins(p) + Player.losses(p),
                                      ratio: Player.ratio(p),
                                      streak: Player.streak(p)} end)
    end

    def undo_last_result() do
      
    end
  end
  