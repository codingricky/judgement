defmodule Judgement.PageController do
  use Judgement.Web, :controller

  alias Judgement.Result
  alias Judgement.GameService

  def index(conn, _params) do
    leaderboard = GameService.leaderboard

    conn
    |> assign(:recent_results, Result.recent)
    |> render "index.html", leaderboard: leaderboard
  end
end
