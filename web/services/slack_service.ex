defmodule Judgement.SlackService do
    alias Judgement.GameService
    alias Judgement.Player
    alias Judgement.Result
    alias Judgement.Repo
    alias Judgement.Quote
    require Logger
    
    @days %{1 => "Monday", 2 => "Tuesday", 3 => "Wednesday", 4 => "Thursday", 5 => "Friday", 6 => "Saturday", 7 => "Sunday"}

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
        Logger.info("#{inspect(player_1)} h2h #{inspect(player_2)}")
        player = Player.with_name(player_1)
        opponent = Player.with_name(player_2)
        if player && opponent do
            h2h = Player.h2h(player, opponent)
            "*#{player.name}* h2h *#{opponent.name}* #{h2h[:wins]} wins #{h2h[:losses]} losses #{Number.Percentage.number_to_percentage(h2h[:ratio], precision: 0)}"    
        else
            ""
        end
    end

    def create_result(winner, loser, times \\ 1) do
        winner_player = Player.with_name(winner)
        loser_player = Player.with_name(loser)
        if winner_player && loser_player do
            GameService.create_result(winner_player, loser_player, times)
            {:ok}
        else 
            message = if winner_player, do: "loser not found", else: "winner not found"
            {:error, message}            
        end
    end

    def lookup(player_name, channel) do
        player = Player.with_name(player_name)
        winning_ratio = Player.winning_ratio_by_day(player)
        last_10_games = Result.last_n(player, 10)
                        |> Enum.map_join("\n", &("#{&1.winner.name} defeated #{&1.loser.name}"))

        h2h_record = Player.all
                        |> filter_out_player(player)
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
        winning_ratio
            |> Enum.map_join("\n", &("#{@days[&1[:day]]} - #{Number.Percentage.number_to_percentage(&1[:ratio], precision: 0)}"))
    end

    defp create_field(title, value, short) do
        %{"title": title, "value": value, "short": short}
    end

    def who_does_this_player_mine(player_name) do
        player = Player.with_name(player_name)

        Result.all_results_sorted(player)
            |> Enum.map(&(%{get_other_player_id(player, &1) =>  get_points_diff(player, &1)}))
            |> Enum.reduce(%{}, fn(result_map, acc) -> merge_result_map(result_map, acc) end)
            |> Enum.map(fn({key, value}) -> {key, value} end)
            |> List.keysort(1)
            |> Enum.map_join("\n", fn {k, v} -> "#{Player.find_by_id(k).name} *#{v} points*" end)
    end

    defp merge_result_map(result_map, acc) do
        Map.merge(acc, result_map, fn(_k, v1, v2) -> v1 + v2 end)
    end

    defp get_other_player_id(player, result) do
        if is_winner?(player, result), do: result.loser.id, else: result.winner.id 
    end

    defp get_points_diff(player, result) do
        if is_winner?(player, result), do: result.winner_rating_after - result.winner_rating_before, else: result.loser_rating_after - result.loser_rating_before
    end

    defp is_winner?(player, result) do
        result.winner.id == player.id
    end

    defp filter_out_player(players, player) do
        Enum.filter(players, &(player.id != &1.id))
    end

    def change_colour(player, colour) do
        case Player.with_name(player)
         |> Player.changeset(%{color: colour})
         |> Repo.update do
             {:ok, _} -> "Updated #{player}'s colour to #{colour}"
             _ -> "Could not update colour. Please choose one of the following colours [green, purple, red, yellow, black, pink, white, cyan,blue]"
         end
    end

    def best_day_to_play(player) do
        best_day = Player.with_name(player)
                        |> Player.winning_ratio_by_day()
                        |> Enum.reduce(fn(day, acc) -> if acc[:ratio] < day[:ratio], do: acc, else: day end)
        @days[best_day[:day]]
    end

    def store_quote(message, slack_id) do
        player = Player.find_by_slack_id(slack_id)
        if player && !Quote.find_by_quote_and_player_id(message, player.id) do
            Logger.info("saving #{inspect(message)} against #{inspect(player.name)}")
            GameService.create_quote(message, player.id)
        end
    end
end