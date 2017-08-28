defmodule Judgement.Quote do
  use Judgement.Web, :model

  alias Judgement.Repo
  alias Judgement.Player

  schema "quotes" do
    field :quote, :string
    
    belongs_to :player, Player

    timestamps()
  end

    def changeset(struct, params \\ %{}) do
        struct
        |> cast(params, [:quote])
        |> cast_assoc(:player)    
        |> validate_required([:quote])
        |> unique_constraint(:quote)    
    end

    def find_by_quote_and_player_id(message, player_id) do
        Repo.get_by(Judgement.Quote, quote: message, player_id: player_id)
            |> Repo.preload(:player)
    end

    def quotes(player) do
        Repo.all(from q in Judgement.Quote,
        where: q.player_id == ^player.id,
        select: q)
    end

    def random_quote(player) do
        Enum.random(quotes(player))
    end

end