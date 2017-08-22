defmodule Judgement.SlackService do
    alias Judgement.GameService
    alias Judgement.Player

    def show do
        GameService.active_leaderboard
        |> Enum.map(&("#{&1[:rank]} *#{&1[:name]}*  _#{&1[:wins]}-#{&1[:losses]}_ `#{&1[:points]} points` _#{Number.Percentage.number_to_percentage(&1[:ratio], precision: 0)} #{&1[:streak]}_"))
        |> Enum.join("\n")
    end

    def create_result(winner, loser, times \\ 1) do
        winner_player = Player.with_name(winner)
        loser_player = Player.with_name(loser)
        GameService.create_result(winner_player, loser_player, times)
    end
end