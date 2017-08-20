defmodule Judgement.ResultController do
    use Judgement.Web, :controller
    
    alias Judgement.Player
    alias Judgement.Result
    alias Judgement.Repo
    alias Judgement.GameService

    def new(conn, _params) do
        changeset = Result.changeset(%Result{})
        player_list = Player.all
                    |> Enum.map &({&1.name, &1.name})
        conn
        |> assign(:player_list, player_list)
        |> render "new.html", changeset: changeset
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
  