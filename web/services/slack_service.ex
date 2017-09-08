defmodule Judgement.SlackService do

    @chat_client Application.get_env(:judgement, :chat_client)
    
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
            message = GameService.create_result(winner_player, loser_player, times, false)
            {:ok, message}
        else 
            message = if winner_player, do: "loser not found", else: "winner not found"
            {:error, message}            
        end
    end

    def lookup(player_name, channel, slack) do
        player = Player.with_name(player_name)
        if (player) do
            winning_ratio = Player.winning_ratio_by_day(player)
            last_10_games = Result.last_n(player, 10)
                            |> Enum.map_join("\n", &("#{&1.winner.name} defeated #{&1.loser.name}"))

            h2h_record = Player.all_active
                            |> filter_out_player(player)
                            |> Enum.sort(&(&1.name < &2.name))
                            |> Enum.map(&(create_field("h2h with #{&1.name}", h2h_message(player, &1), false)))
                            
            attachments = [%{"color": "green", 
                            "title": player.name,
                            "image_url": (if player.avatar_url, do: player.avatar_url, else: ""),
                            "fields": [create_field("wins", Player.wins(player), true),
                                        create_field("losses", Player.losses(player), true),
                                        create_field("winning %", Number.Percentage.number_to_percentage(Player.ratio(player), precision: 0), true),
                                        create_field("winning % by day", winning_percent_by_day(winning_ratio), false),
                                        create_field("Last 10 Results", last_10_games, false)] ++ h2h_record}]
            
            SlackClient.post_message(channel, "", %{attachments: Poison.encode!(attachments)})
        else
            SlackClient.send_message("#{player_name} not found", channel, slack)          
        end

    end

    defp h2h_message(player, opponent) do
        h2h_record = Player.h2h(player, opponent)
        "wins #{h2h_record[:wins]} losses #{h2h_record[:losses]} #{Number.Percentage.number_to_percentage(h2h_record[:ratio], precision: 0)}"
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

        if player do
                Result.all_results_sorted(player)
                    |> Enum.map(&(%{get_other_player_id(player, &1) =>  get_points_diff(player, &1)}))
                    |> Enum.reduce(%{}, fn(result_map, acc) -> merge_result_map(result_map, acc) end)
                    |> Enum.map(fn({key, value}) -> {key, value} end)
                    |> List.keysort(1)
                    |> Enum.map_join("\n", fn {k, v} -> "#{Player.find_by_id(k).name} *#{v} points*" end)    
        else
            ""
        end
        
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

    def best_day_to_play(name) do
       Player.best_day_to_play(name)
    end

    def store_quote(message, slack_id) do
        player = player_from_slack_id(slack_id)
        Logger.info("resolved #{slack_id} to #{inspect(player)}")
        store_avatar(player, slack_id)
        if player && !Quote.find_by_quote_and_player_id(message, player.id) do
            Logger.info("saving #{inspect(message)} against #{inspect(player.name)}")
            GameService.create_quote(message, player.id)
        end
    end

    def store_avatar(player, slack_id) do
        if player.avatar_url == nil do
            GameService.update_avatar_url(player, get_avatar_url_from_slack_id(slack_id))
        end        
    end

    defp get_name_from_slack_id(slack_id) do
        @chat_client.get_name_from_slack_id(slack_id)
    end

    defp player_from_slack_id(slack_id) do
        Player.with_name(get_name_from_slack_id(slack_id))        
    end

    def get_avatar_url_from_slack_id(slack_id) do
        @chat_client.get_avatar_url_from_slack_id(slack_id)
    end

    def what_would_player_say(player_name, channel, slack) do
        message = Player.with_name(player_name)
                    |> Player.random_quote()
        @chat_client.send_message("*#{player_name}* says _#{message}_", channel, slack)
    end

    def who_should_i_play(slack_id, channel, slack) do
        name = get_name_from_slack_id(slack_id)
        message = case Player.with_name(name) do
            nil -> "#{name} can not be found"
            player -> potential_opponents(player)
        end
        @chat_client.send_message(channel, message, slack)
    end

    def what_if_i_played(slack_id, channel, slack, opponent_name) do
        name = get_name_from_slack_id(slack_id)
        player = Player.with_name(name)
        opponent = Player.with_name(opponent_name)
        message = case (player != nil && name != nil) do
            true -> "*If* you beat *#{opponent_name}*, you would get `#{calculate_points_diff(player, opponent)} points`"
            false -> "Could not find players"            
        end

        @chat_client.send_message(channel, message, slack)            
    end

    defp potential_opponents(player) do
        Player.all_active
        |> Enum.filter(&(&1.id != player.id))
        |> Enum.map(&(%{name: &1.name, potential_points: calculate_points_diff(player, &1)}))
        |> Enum.sort(&(&1[:potential_points] > &2[:potential_points]))
        |> Enum.map(&("*If* you beat *#{&1[:name]}*, you would get `#{&1[:potential_points]} points`"))
        |> Enum.join("\n")
    end

    defp calculate_points_diff(winner, opponent) do
        if (winner.id == opponent.id) do
            0
        else
            {winner_after, _loser_after} = GameService.calculate_result(winner.rating.value, opponent.rating.value)
            winner_after - winner.rating.value
        end
    end
end