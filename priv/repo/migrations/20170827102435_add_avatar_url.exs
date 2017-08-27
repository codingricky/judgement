defmodule Judgement.Repo.Migrations.AddAvatarUrl do
  use Ecto.Migration

  def change do
    alter table(:players) do
      add :avatar_url, :string
    end
  end
end
