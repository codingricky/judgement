defmodule Judgement.ResultView do
    use Judgement.Web, :view

    def player_list(conn) do
        conn.assigns.player_list
    end
end  