defmodule Judgement.GameService do
    alias Judgement.Repo
    alias Judgement.Player
    alias Judgement.Rating
    alias Judgement.Result
    alias Judgement.Quote
    require Logger

    def create_quote(message, player_id) do
      player = Player.find_by_id(player_id)
      Logger.info("saving #{inspect(message)} against #{inspect(player_id)}")
      %Quote{quote: message, player: player}
                          |> Repo.insert
    end

    def create_player(name, email) do
       Player.changeset(%Player{}, %{name: name, email: email, rating: %{}})
                          |> Repo.insert
    end

    def create_player(name, email, color) do
       Player.changeset(%Player{}, %{name: name, email: email, color: color, rating: %{}})
                          |> Repo.insert
    end

    def update_player(name, email) do
      Player.changeset(%Player{}, %{name: name, email: email})
                         |> Repo.update
    end

    def update_avatar_url(player, avatar_url) do
      Player.changeset(player, %{avatar_url: avatar_url})
              |> Repo.update
    end

    def find_player(email) do
      Repo.get_by(Player, email: email)
      |> Repo.preload(:rating)
    end

    def create_result(winner, loser, times \\ 1) do
      winner_rating_before = get_rating(winner).value
      loser_rating_before = get_rating(loser).value
      
      do_create_result(winner, loser, times)

      winner_rating_after = get_rating(winner).value
      loser_rating_after = get_rating(loser).value

      message = compose_message(winner.name, winner_rating_before, winner_rating_after, loser.name, loser_rating_before, loser_rating_after, times)
      if  Mix.env != :test do
        channel = "tabletennis-testing"
        Slack.Web.Chat.post_message(channel, message)
      end
    end
  
    defp compose_message(winner, winner_rating_before, winner_rating_after, loser, loser_rating_before, loser_rating_after, times) do
      ":table_tennis_paddle_and_ball: #{message(winner, winner_rating_before, winner_rating_after)} defeats #{message(loser, loser_rating_before, loser_rating_after)} #{multipler(times)}" 
    end

    defp message(name, rating_before, rating_after) do
      "*#{name}* (~#{rating_before}~) - (#{rating_after})"
    end

    defp multipler(times) do
      if times > 1 do
        "#{times} times"
      else
        ""
      end 
    end
    
    defp do_create_result(_winner, _loser, 0) do
    end 

    defp do_create_result(winner, loser, times) do 
      winner_rating = Rating |> Repo.get(winner.rating.id)
      winner_rating_before = winner_rating.value
      loser_rating = Rating |> Repo.get(loser.rating.id)      
      loser_rating_before = loser_rating.value
      {winner_rating_after, loser_rating_after} = Elo.rate(winner_rating_before, loser_rating_before, :win, k_factor: 15, round: :down)

      Ecto.Changeset.change(winner.rating, %{value: winner_rating_after})
        |> Repo.update

      Ecto.Changeset.change(loser.rating, %{value: loser_rating_after})
        |> Repo.update

      %Result{winner: winner, 
              loser: loser,
              winner_rating_before: winner_rating_before,
              winner_rating_after: winner_rating_after,
              loser_rating_before: loser_rating_before,
              loser_rating_after: loser_rating_after}
              |> Repo.insert

        do_create_result(winner, loser, times - 1)
    end

    defp get_rating(player) do
        Rating |> Repo.get(player.rating.id)
    end

    def undo_last_result() do
      [first | _] = Result.all_sorted_by_creation_date
      winner_rating_before = first.winner_rating_before
      loser_rating_before = first.loser_rating_before

      winner = Player |> Repo.get(first.winner_id) |> Repo.preload(:rating)
      loser = Player |> Repo.get(first.loser_id) |> Repo.preload(:rating)
      
      Ecto.Changeset.change(winner.rating, %{value: winner_rating_before})
        |> Repo.update

      Ecto.Changeset.change(loser.rating, %{value: loser_rating_before})
        |> Repo.update

      Repo.delete(first)
    end

    def leaderboard() do
      all_players_with_index()
        |> convert_players_to_leaderboard_map
    end

    def active_leaderboard() do
      Player
        |> Repo.all
        |> Repo.preload(:rating)
        |> Enum.filter(&(Player.is_active?(&1)))
        |> Enum.sort(&(&1.rating.value > &2.rating.value))
        |> Enum.with_index(1)        
        |> convert_players_to_leaderboard_map
    end

    def reverse_active_leaderboard() do
      Player
        |> Repo.all
        |> Repo.preload(:rating)
        |> Enum.filter(&(Player.is_active?(&1)))
        |> Enum.sort(&(&1.rating.value < &2.rating.value))
        |> Enum.with_index(1)        
        |> convert_players_to_leaderboard_map
    end

    def all_players_with_index() do
      Player
        |> Repo.all
        |> Repo.preload(:rating)
        |> Enum.sort(&(&1.rating.value > &2.rating.value))
        |> Enum.with_index(1)
    end

    def convert_players_to_leaderboard_map(player) do
      Enum.map(player, fn {p, index} -> %{rank: index, 
                                      player_id: p.id,
                                      points: p.rating.value, 
                                      name: p.name,
                                      wins: Player.wins(p),
                                      losses: Player.losses(p),
                                      color: p.color,
                                      total: Player.wins(p) + Player.losses(p),
                                      ratio: Player.ratio(p),
                                      streak: Player.streak(p)} end)
    end
  end
  