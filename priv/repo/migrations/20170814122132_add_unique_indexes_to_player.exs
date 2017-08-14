defmodule Judgement.Repo.Migrations.AddUniqueIndexesToPlayer do
  use Ecto.Migration

  def change do
    create unique_index(:players, [:name])
    create unique_index(:players, [:email])
  end
end
