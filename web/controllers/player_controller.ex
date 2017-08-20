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
        case GameService.create_player(name, email) do
            {:ok, _} -> redirect(conn)
            {:error, changeset} -> render_page(conn, changeset)
        end
    end

    defp redirect(conn) do
        conn |> Phoenix.Controller.redirect(to: page_path(@conn, :index)) |> halt        
    end

    defp render_page(conn, changeset) do
        render conn, "new.html", changeset: changeset        
    end
  end
  