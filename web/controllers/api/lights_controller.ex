defmodule Judgement.LightsController do
    use Judgement.Web, :controller

    alias Judgement.Player

    def index(conn, _params) do
        render conn, "index.json", players: Player.all_active        
    end        
end