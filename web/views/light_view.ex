defmodule Judgement.LightsView do
    use Judgement.Web, :view

    alias Judgement.Player

    def render("index.json", %{players: players}) do
        players |> Enum.map(&(convert_to_json(&1)))
    end

    defp convert_to_json(player) do
        %{player: %{name: player.name, 
                    email: player.email,
                    wins: Player.wins(player),
                    losses: Player.losses(player),
                    win_loss_ratio: Player.ratio(player),
                    streak: Player.streak(player),
                    color: player.color}, 
        value: player.rating.value}
    end
end  