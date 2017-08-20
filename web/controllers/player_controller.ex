defmodule Judgement.PlayerController do
    use Judgement.Web, :controller
    
    alias Judgement.Player
    alias Judgement.Repo
    alias Judgement.GameService

    def new(conn, _params) do
        changeset = Player.changeset(%Player{})
        render conn, "new.html", changeset: changeset
    end

    def create(conn, %{"player" => %{"name" => name, "email" => email}}) do
        player = GameService.create_player(name, email)
        conn |> Phoenix.Controller.redirect(to: "/") |> halt
    end
  end
  