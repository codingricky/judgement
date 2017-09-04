require IEx

defmodule Judgement.Result do
  use Judgement.Web, :model
  alias Judgement.Player
  alias Judgement.Repo

  schema "results" do
    belongs_to :winner, Player
    belongs_to :loser, Player

    field :winner_rating_before, :integer
    field :winner_rating_after, :integer
    field :loser_rating_before, :integer
    field :loser_rating_after, :integer
    field :created_date, :date

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:winner_id, :loser_id, :winner_rating_before, :winner_rating_after, :loser_rating_before, :loser_rating_after, :created_date])
    |> validate_required([:winner_id, :loser_id, :winner_rating_before, :winner_rating_after, :loser_rating_before, :loser_rating_after, :created_date])
  end

     
  def all do
    Judgement.Result |> Repo.all |> Repo.preload(:winner) |> Repo.preload(:loser)
  end

  def recent do
    Repo.all(from r in Judgement.Result,
            limit: 20,
             order_by: [desc: r.inserted_at]) 
        |> Repo.preload(:winner) 
        |> Repo.preload(:loser)
  end

  def recent(player) do
    last_n(player, 20)
  end

  def last_n(player, n) do
    all_results_sorted(player)
      |> Enum.slice(0..n)  
  end

  def all_sorted_by_creation_date do 
      Repo.all(from r in Judgement.Result,
                  order_by: [desc: r.inserted_at]) 
      |> Repo.preload(:winner) 
      |> Repo.preload(:loser)
  end

  def all_results_sorted(player) do
    all_wins_sorted(player) ++ all_losses_sorted(player)
            |> Repo.preload(:winner) 
            |> Repo.preload(:loser)
            |> Enum.sort(&(&1.id > &2.id))
  end

  def all_losses_sorted(player) do
    Repo.all(from r in Judgement.Result,
            join: (p in assoc(r, :loser)),
            where: p.id == ^player.id,
            select: r,
            order_by: [desc: r.inserted_at])
  end

  def all_wins_sorted(player) do
    Repo.all(from r in Judgement.Result,
            join: (p in assoc(r, :winner)),
            where: p.id == ^player.id,
            select: r,
            order_by: [desc: r.inserted_at])
  end

  def no_of_wins(player) do
      Repo.one(from r in Judgement.Result,
            join: p in assoc(r, :winner),
          where: p.id == ^player.id,
          select: count(r.id))
  end

  def no_of_losses(player) do
      Repo.one(from r in Judgement.Result,
            join: p in assoc(r, :loser),
          where: p.id == ^player.id,
          select: count(r.id))
  end

  def ratio(player) do
    wins = no_of_wins(player)
    losses = no_of_losses(player)
    total = wins + losses
    case total do
      0 ->
        0
      _ ->
        wins/total * 100
    end
  end

  def no_of_wins_against(player, opponent) do
      Repo.one(from r in Judgement.Result,
                join: p in assoc(r, :winner),
                where: p.id == ^player.id,
                join: l in assoc(r, :loser),
                where: l.id == ^opponent.id,
                select: count(r.id))
  end

  def no_of_losses_against(player, opponent) do
    Repo.one(from r in Judgement.Result,
              join: p in assoc(r, :loser),
              where: p.id == ^player.id,
              join: w in assoc(r, :winner),
              where: w.id == ^opponent.id,
              select: count(r.id))
  end

  def no_of_recent_games(player, date) do
    Repo.one(from r in Judgement.Result,
            join: p in assoc(r, :winner),
            where: p.id == ^player.id,
            where: r.inserted_at > ^date,
            select: count(r.id)) +
      Repo.one(from r in Judgement.Result,
            join: p in assoc(r, :loser),
            where: p.id == ^player.id,
            where: r.inserted_at > ^date,
            select: count(r.id))
  end

  def day(result) do
    Date.day_of_week(NaiveDateTime.to_date(result.inserted_at))
  end
end
