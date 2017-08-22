defmodule Judgement.PlayerController do
    use Judgement.Web, :controller
    
    alias Judgement.Player
    alias Judgement.Result    
    alias Judgement.Repo
    alias Judgement.GameService

    def new(conn, _params) do
        changeset = Player.changeset(%Player{})
        render conn, "new.html", changeset: changeset
    end

    def show(conn, %{"id" => id}) do
        player = Player.find_by_id(id)
        head_to_head = Player.all
                    |> Enum.filter(&(&1 != player))
                    |> Enum.map(&(Player.h2h(player, &1)))
                    |> Enum.sort(&(&1[:rating] > &2[:rating]))

        results = Result.recent(player)
        render conn, "show.html", player: player, id: id, head_to_head: head_to_head, results: results     
    end
    
    def edit(conn, %{"id" => id}) do
        changeset = Player.changeset(Player.find_by_id(id))
        render conn, "edit.html", changeset: changeset, id: id       
    end

    def create(conn, %{"player" => %{"name" => name, "email" => email, "color" => _color}}) do
        case GameService.create_player(name, email) do
            {:ok, _} -> redirect(conn)
            {:error, changeset} -> render_page(conn, changeset)
        end
    end

    def update(conn, %{"id" => id, "player" => %{"name" => name, "email" => email, "color" => color}}) do
        changeset = Player.changeset(Player.find_by_id(id), %{name: name, email: email, color: color})
                    |> Repo.update

        case changeset do
            {:ok, _} -> redirect(conn)
            {:error, changeset} -> render conn, "edit.html", changeset: changeset    
        end
    end

    defp redirect(conn) do
        conn |> Phoenix.Controller.redirect(to: page_path(conn, :index)) |> halt        
    end

    defp render_page(conn, changeset) do
        render conn, "new.html", changeset: changeset        
    end
  end
  