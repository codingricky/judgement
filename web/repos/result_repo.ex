defmodule Judgement.ResultRepo do
    alias Judgement.Repo
    alias Judgement.Player
    alias Judgement.Rating
    alias Judgement.Result
    import Ecto.Query
    
    def all do
        Result |> Repo.all |> Repo.preload(:winner) |> Repo.preload(:loser)
    end

    def no_of_wins(player) do
        Repo.one(from r in Result,
              join: p in assoc(r, :winner),
             where: p.id == ^player.id,
            select: count(r.id))
    end

    def no_of_losses(player) do
        Repo.one(from r in Result,
              join: p in assoc(r, :loser),
             where: p.id == ^player.id,
            select: count(r.id))
    end
end