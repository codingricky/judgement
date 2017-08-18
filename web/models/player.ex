defmodule Judgement.Player do
  use Judgement.Web, :model

  alias Judgement.Rating
  alias Judgement.Repo
  alias Judgement.Result

  schema "players" do
    field :name, :string
    field :email, :string
    has_one :rating, Rating, on_delete: :delete_all

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :email])
    |> validate_required([:name, :email])
  end

  def first do
    [first_element, _] = all()
    first_element 
  end

  def all do
    Judgement.Player |> Repo.all |> Repo.preload(:rating)
  end

  def wins(player) do
    Result.no_of_wins(player)
  end

  def losses(player) do
    Result.no_of_losses(player)
  end

  def ratio(player) do
    Result.ratio(player)
  end

end
