defmodule Judgement.PageView do
  use Judgement.Web, :view

  alias Judgement.Result
  alias Judgement.Player
  
  def recent_results(conn) do
    conn.assigns.recent_results
  end

  def minutes_ago(result) do
    diff = NaiveDateTime.diff(NaiveDateTime.utc_now, result.inserted_at)
    round(Float.floor(diff/60))
  end

  def streak(player) do
    Player.find_by_id(player.player_id)
      |> Result.last_n(10)
      |> Enum.map &(convert_to_char(&1, player)) 
  end

  def convert_to_char(result, player) do
    if result.winner.id == player.player_id do
      "W" 
    else
      "L"
    end
  end
end
