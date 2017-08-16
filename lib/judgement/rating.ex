defmodule Judgement.Rating do
  use Ecto.Schema
  import Ecto.Changeset
  alias Judgement.Rating


  schema "ratings" do
    field :value, :integer, default: 1000
    belongs_to :player, Player

    timestamps()
  end

  @doc false
  def changeset(%Rating{} = rating, attrs) do
    rating
    |> cast(attrs, [:value])
    |> validate_required([:value])
  end
end
