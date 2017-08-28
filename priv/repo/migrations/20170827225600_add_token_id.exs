defmodule Judgement.Repo.Migrations.AddTokenId do
  use Ecto.Migration

  def change do
    alter table(:players) do
      add :token_id, :string
    end
  end
end
