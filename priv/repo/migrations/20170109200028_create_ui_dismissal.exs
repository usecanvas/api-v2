defmodule CanvasAPI.Repo.Migrations.CreateUIDismissal do
  use Ecto.Migration

  def change do
    create table(:ui_dismissals, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :identifier, :text
      add :account_id, references(:accounts, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create unique_index(:ui_dismissals, [:account_id, :identifier])
  end
end
