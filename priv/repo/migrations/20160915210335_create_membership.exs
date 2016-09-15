defmodule CanvasAPI.Repo.Migrations.CreateMembership do
  use Ecto.Migration

  def change do
    create table(:memberships, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :identity_token, :text, null: false
      add :team_id, references(:teams, on_delete: :delete_all, type: :binary_id), null: false
      add :account_id, references(:accounts, on_delete: :delete_all, type: :binary_id), null: false
      add :inserted_at, :timestamptz, null: false
      add :updated_at, :timestamptz, null: false
    end

    create index(:memberships, [:account_id, :team_id], unique: true)
  end
end
