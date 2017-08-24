defmodule Judgement.Repo.Migrations.AddQuotesTable do
  use Ecto.Migration

  def change do
    create table(:quotes) do
      add :quote, :string
      add :player_id, references(:players)

      timestamps()
    end
  end
end
