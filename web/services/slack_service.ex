defmodule Judgement.SlackService do
    alias Judgement.GameService
    alias Judgement.Player

    def show do
        GameService.active_leaderboard
        |> convert_leaderboard_to_string
    end

    def show_full do
        GameService.leaderboard
        |> convert_leaderboard_to_string
    end

    def reverse_show do
        GameService.reverse_active_leaderboard
        |> convert_leaderboard_to_string
    end

    def convert_leaderboard_to_string(leaderboard) do
        leaderboard
        |> Enum.map(&("#{&1[:rank]}. *#{&1[:name]}*  _#{&1[:wins]}-#{&1[:losses]}_ `#{&1[:points]} points` _#{Number.Percentage.number_to_percentage(&1[:ratio], precision: 0)} #{&1[:streak]}_"))
        |> Enum.join("\n")
    end

    def h2h(player_1, player_2) do
        player = Player.with_name(player_1)
        opponent = Player.with_name(player_2)
        h2h = Player.h2h(player, opponent)

        "*#{player.name}* h2h *#{opponent.name}* #{h2h[:wins]} wins #{h2h[:losses]} losses #{Number.Percentage.number_to_percentage(h2h[:ratio], precision: 0)}"
    end

    def create_result(winner, loser, times \\ 1) do
        winner_player = Player.with_name(winner)
        loser_player = Player.with_name(loser)
        GameService.create_result(winner_player, loser_player, times)
    end
end