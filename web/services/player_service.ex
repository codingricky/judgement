defmodule Judgement.PlayerService do
    alias Judgement.Repo
    alias Judgement.Player
    alias Judgement.Rating

    def create_player(name, email) do
       result = %Player{name: name, email: email, rating: %Rating{}}
                          |> Repo.insert
       case result do
        {:ok, player} -> player
        {:error, player} -> raise "problems creating a player" 
       end
    end


  end
  