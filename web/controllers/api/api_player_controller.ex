require IEx

defmodule Judgement.ApiPlayerController do
    use Judgement.Web, :controller

    alias Judgement.Player
    
    def index(conn, %{"name" => name}) do
        player = Player.with_name(name)
        if (player) do
            render conn, "index.json", player: player        
        else
            send_not_found(conn)
        end
    end

    defp send_not_found(conn) do
        conn
        |> send_resp(404, "player not found")
        |> halt    
    end
end