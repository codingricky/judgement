defmodule Judgement.PageController do
  use Judgement.Web, :controller

  alias Judgement.Result
  alias Judgement.GameService

  def index(conn, _params) do
    leaderboard = GameService.active_leaderboard()

    conn
    |> assign(:recent_results, Result.recent)
    |> render("index.html", leaderboard: leaderboard)
  end

  def undo(conn, _params) do
    GameService.undo_last_result()

    conn
    |> redirect
  end

  defp redirect(conn) do
    conn |> Phoenix.Controller.redirect(to: "/") |> halt        
  end
end
