defmodule Judgement.Factory do
    use ExMachina.Ecto, repo: Judgement.Repo
    def player_factory do
        %Judgement.Player{
        name: "John Smith",
        email: sequence(:email, &"email-#{&1}@example.com"),
        }
    end
end