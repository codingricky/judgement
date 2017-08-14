defmodule Judgement.Repo.Migrations.CreateRatings do
  use Ecto.Migration

  def change do
    create table(:ratings) do
      add :value, :integer

      timestamps()
    end

  end
end
