defmodule Judgement.Repo.Migrations.AddRatingToPlayer do
  use Ecto.Migration

  def change do
    alter table(:players) do
      add :rating_id, references(:ratings)
    end
  end
end
