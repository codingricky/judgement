defmodule Judgement.Repo.Migrations.AddPlayerIdToRating do
  use Ecto.Migration

  def change do
    alter table(:ratings) do
      add :player_id, references(:players)
    end
  end
end
