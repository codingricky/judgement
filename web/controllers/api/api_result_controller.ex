defmodule Judgement.ApiResultController do
    use Judgement.Web, :controller

    alias Judgement.GameService
    alias Judgement.Player
    
    def create(conn, %{"winner" => winner, "loser" => loser, "times" => times}) do
        message = GameService.create_result(Player.with_name(winner), Player.with_name(loser), String.to_integer(times))
        render conn, "index.json", message: message        
    end

    def create(conn, %{"winner" => winner, "loser" => loser}) do
        message = GameService.create_result(Player.with_name(winner), Player.with_name(loser), 1)
        render conn, "index.json", message: message        
    end
end