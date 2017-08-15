defmodule Judgement.Result do
  use Judgement.Web, :model
  alias Judgement.Player

  schema "results" do
    has_one :winner, Player
    has_one :loser, Player

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
end
