defmodule Judgement.Repo.Migrations.ChangeColumnNamesInResults do
  use Ecto.Migration

  def change do
    alter table(:results) do
      remove :winner_ratings_before
      remove :winner_ratings_after
      remove :loser_ratings_before
      remove :loser_ratings_after

      add :winner_rating_before, :integer
      add :winner_rating_after, :integer
      add :loser_rating_before, :integer
      add :loser_rating_after, :integer
    end
  end
end
