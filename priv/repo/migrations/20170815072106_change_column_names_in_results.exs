defmodule Judgement.Repo.Migrations.ChangeColumnNamesInResults do
  use Ecto.Migration

  def change do
    alter table(:results) do
      remove :winner_points_before
      remove :winner_points_after
      remove :loser_points_before
      remove :loser_points_after

      add :winner_ratingg_before, :integer
      add :winner_rating_after, :integer
      add :loser_rating_before, :integer
      add :loser_rating_after, :integer
    end
  end
end
