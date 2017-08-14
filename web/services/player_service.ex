defmodule Judgement.PlayerService do
    alias Judgement.Repo
    alias Judgement.Player
    alias Judgement.Rating

    def create_player(name, email) do
       case %Player{name: name, email: email, rating: %Rating{}}
        |> Repo.insert do 
        {:ok, struct} ->
        {:error, changeset} -> 

    end


  end
  