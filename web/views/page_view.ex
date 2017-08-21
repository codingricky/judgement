defmodule Judgement.PageView do
  use Judgement.Web, :view
  
  def recent_results(conn) do
    conn.assigns.recent_results
  end

  def minutes_ago(result) do
    diff = NaiveDateTime.diff(NaiveDateTime.utc_now, result.inserted_at)
    round(Float.floor(diff/60))
  end
end
