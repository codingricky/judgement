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

  def h2h(player, opponent) do
    %{wins: Result.no_of_wins_against(player, opponent), 
      losses: Result.no_of_losses_against(player, opponent)}
  end
end
