defmodule CanvasAPI.Repo.Migrations.AddNameToAccounts do
  use Ecto.Migration

  def change do
    alter table(:accounts) do
      add :name, :string, null: false
    end
  end
end
