defmodule Judgement.PlayerRepo do
    alias Judgement.Repo
    alias Judgement.Player
    alias Judgement.Rating
    alias Judgement.Result

    def first do
        [first_element] = all
        first_element 
    end

    def all do
        Player |> Repo.all |> Repo.preload(:rating)
    end

end