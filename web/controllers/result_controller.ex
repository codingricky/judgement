require IEx

defmodule Judgement.ResultController do
    use Judgement.Web, :controller
    
    alias Judgement.Player
    alias Judgement.Result
    alias Judgement.Repo
    alias Judgement.GameService

    def full_rankings(conn, _params) do 
        end

    def new(conn, _params) do
        conn
        |> get_player_list
        |> render_page
    end

    def create(conn, %{"result" => %{"winner" => winner_name, "opponent" => loser_name, "times" => times}}) do
        winner = Player.find_by_name(winner_name)
        loser = Player.find_by_name(loser_name)
        {parsed_times, _} = Integer.parse(times)
        if (winner == loser) do
            conn
            |> put_flash(:info, "Winner can not be the same as loser")
            |> get_player_list
            |> render_page
        else
            GameService.create_result(winner, loser, parsed_times)
            conn
            |> redirect
        end
    end

    defp redirect(conn) do
        conn |> Phoenix.Controller.redirect(to: page_path(conn, :index)) |> halt        
    end

    defp render_page(conn) do
        render conn, "new.html"
    end

    defp get_player_list(conn) do
        player_list = Player.all
            |> Enum.map &({&1.name, &1.name})

        assign(conn, :player_list, player_list)
    end
  end
  