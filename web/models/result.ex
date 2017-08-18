defmodule Judgement.Result do
  use Judgement.Web, :model
  alias Judgement.Player
  alias Judgement.Rating
  alias Judgement.Repo

  schema "results" do
    belongs_to :winner, Player
    belongs_to :loser, Player

    field :winner_rating_before, :integer
    field :winner_rating_after, :integer
    field :loser_rating_before, :integer
    field :loser_rating_after, :integer

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:winner_id, :loser_id, :winner_rating_before, :winner_rating_after, :loser_rating_before, :loser_rating_after])
    |> validate_required([:winner_id, :loser_id, :winner_rating_before, :winner_rating_after, :loser_rating_before, :loser_rating_after])
  end

     
  def all do
    Judgement.Result |> Repo.all |> Repo.preload(:winner) |> Repo.preload(:loser)
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
    case losses do
      {0} ->
        wins/losses
      {_} ->
        0
    end
  end

end
