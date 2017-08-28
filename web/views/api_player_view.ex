defmodule Judgement.ApiPlayerView do
    use Judgement.Web, :view

    alias Judgement.Player
    alias Judgement.GameService

    def render("index.json", %{player: player}) do
        case GameService.leaderboard_info(player) do
            %{rank: rank, points: points, color: color} -> %{"rank" => rank, 
                                                            "points" => points, 
                                                            "color" => color, 
                                                            "day" => Player.best_day_to_play(player.name), 
                                                            "avatar_url" => player.avatar_url,
                                                            "quote" => Player.random_quote(player)}
             _ -> "not found"
        end
    end
end  