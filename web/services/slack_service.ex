defmodule Judgement.SlackService do
    alias Judgement.GameService
    alias Judgement.Player
    alias Judgement.Result

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

    def lookup(player_name, channel) do
        player = Player.with_name(player_name)
        winning_ratio = Player.winning_ratio_by_day(player)
        last_10_games = Result.last_n(player, 10)
                        |> Enum.map_join("\n", &("#{&1.winner.name} defeated #{&1.loser.name}"))

        h2h_record = Player.all
                        |> Enum.filter(&(player.id != &1.id))
                        |> Enum.sort(&(&1.name < &2.name))
                        |> Enum.map_join("\n", &(h2h_message(player, &1)))

        attachments = [%{"color": "green", 
                         "title": player.name,
                         "fields": [create_field("wins", Player.wins(player), true),
                                    create_field("losses", Player.losses(player), true),
                                    create_field("winning %", Number.Percentage.number_to_percentage(Player.ratio(player), precision: 0), true),
                                    create_field("winning % by day", winning_percent_by_day(winning_ratio), false),
                                    create_field("Last 10 Results", last_10_games, false),
                                    create_field("h2h", h2h_record, false)]}]
        
        Slack.Web.Chat.post_message(channel, "", %{attachments: Poison.encode!(attachments)})
    end

    defp h2h_message(player, opponent) do
        h2h_record = Player.h2h(player, opponent)
        "h2h with #{opponent.name} wins #{h2h_record[:wins]} losses #{h2h_record[:losses]} #{Number.Percentage.number_to_percentage(h2h_record[:ratio], precision: 0)}"
    end

    defp winning_percent_by_day(winning_ratio) do
        days = %{1 => "Monday", 2 => "Tuesday", 3 => "Wednesday", 4 => "Thursday", 5 => "Friday", 6 => "Saturday", 7 => "Sunday"}
        winning_ratio
            |> Enum.map_join("\n", &("#{days[&1[:day]]} - #{Number.Percentage.number_to_percentage(&1[:ratio], precision: 0)}"))
    end

    defp create_field(title, value, short) do
        %{"title": title, "value": value, "short": short}
    end
end