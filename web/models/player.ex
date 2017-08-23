defmodule Judgement.Player do
  use Judgement.Web, :model

  alias Judgement.Rating
  alias Judgement.Repo
  alias Judgement.Result

  schema "players" do
    field :name, :string
    field :email, :string
    field :color, :string
    
    has_one :rating, Rating, on_delete: :delete_all

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :email, :color])
    |> cast_assoc(:rating)    
    |> validate_required([:name, :email])
    |> unique_constraint(:email)
    |> unique_constraint(:name)    
  end

  def first do
    [first_element, _] = all()
    first_element 
  end

  def all do
    Repo.all(from p in Judgement.Player,
              select: p,
              order_by: [asc: p.name]) |> Repo.preload(:rating)
  end

  def wins(player) do
    Result.no_of_wins(player)
  end

  def losses(player) do
    Result.no_of_losses(player)
  end

  def no_of_games(player) do
    Result.all_results_sorted(player)
    |> length
  end

  def no_of_recent_games(player, date) do
    Result.no_of_recent_games(player, date)
  end

  def ratio(player) do
    Result.ratio(player)
  end

  def streak(player) do
    results = Result.all_results_sorted(player)
    consecutive_wins(results, player, 0)
  end

  defp consecutive_wins([head | tail], player, streak) do
      is_win? = head.winner_id == player.id
      if is_win? do
        consecutive_wins(tail, player, streak + 1)
      else
        streak
      end
  end

  defp consecutive_wins([], _player, streak) do
    streak
  end

  def find(email) do
    Repo.get_by(Judgement.Player, email: email)
    |> Repo.preload(:rating)
  end

  def find_by_id(id) do
    Repo.get(Judgement.Player, id)
    |> Repo.preload(:rating)
  end

  def find_by_name(name) do
    Repo.get_by(Judgement.Player, name: name)
    |> Repo.preload(:rating)
  end

  def with_name(name) do
    search = "#{name}%"
      Repo.one(from p in Judgement.Player,
              where: ilike(p.name, ^search),
              select: p)
      |> Repo.preload(:rating)
  end

  def h2h(player, opponent) do
    wins = Result.no_of_wins_against(player, opponent)
    losses = Result.no_of_losses_against(player, opponent)
    total = wins + losses
    ratio = case total do
      0 ->  0
      _ -> wins/total * 100
    end

    %{wins: wins, 
      losses: losses,
      opponent: opponent,
      rating: opponent.rating.value,
      ratio: ratio}
  end

  def is_active?(player) do
    day_in_seconds = 60 * 60 * 24    
    twenty_days_ago = NaiveDateTime.utc_now
                          |> NaiveDateTime.add(-1 * day_in_seconds * 20, :second)

    no_of_recent_games(player, twenty_days_ago) >= 10
  end
end
