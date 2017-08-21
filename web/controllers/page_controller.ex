defmodule Judgement.PageController do
  use Judgement.Web, :controller

  alias Judgement.Result

  def index(conn, _params) do
    conn
    |> assign(:recent_results, Result.recent)
    |> render "index.html"
  end
end
