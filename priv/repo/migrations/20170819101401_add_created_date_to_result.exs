defmodule Judgement.Repo.Migrations.AddCreatedDateToResult do
  use Ecto.Migration

  def change do
    alter table(:results) do
      add :created_date, :date
    end
  end
end
