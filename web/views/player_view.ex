require IEx

defmodule Judgement.PlayerView do
    use Judgement.Web, :view

    def result_message(player_id, result) do
        if result.winner_id == String.to_integer(player_id) do
            "Won against"
        else
            "Lost against"
        end 
    end

    def result_name(player_id, result) do
        if result.winner_id == String.to_integer(player_id) do
            result.loser.name
        else
            result.winner.name
        end 
    end
end  