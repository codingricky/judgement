defmodule Judgement.Repo.Migrations.AddColour do
  use Ecto.Migration

  def change do
    alter table(:players) do
      add :color, :string
    end
  end
end
