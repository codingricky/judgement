defmodule Judgement.Repo.Migrations.CreateResult do
  use Ecto.Migration

  def change do
    create table(:results) do
      add :winner_id, :integer
      add :loser_id, :integer

      add :winner_rating_before, :integer
      add :winner_rating_after, :integer
      add :loser_rating_before, :integer
      add :loser_rating_after, :integer

      timestamps()
    end
  end
end
