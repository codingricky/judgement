defmodule Judgement.Player do
  use Judgement.Web, :model

  alias Judgement.Rating

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
end
