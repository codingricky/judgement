defmodule Judgement.SlackService do
    alias Judgement.GameService

    def show do
        GameService.active_leaderboard
        |> Enum.map(&("#{&1[:rank]} *#{&1[:name]}*  _#{&1[:wins]}-#{&1[:losses]}_ `#{&1[:points]} points` _#{Number.Percentage.number_to_percentage(&1[:ratio], precision: 0)} #{&1[:streak]}_"))
        |> Enum.join("\n")
    end
end