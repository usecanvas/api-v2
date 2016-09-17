defmodule CanvasAPI.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :email, :text, null: false
      add :identity_token, :text, null: false
      add :images, :jsonb, null: false, default: fragment("'{}'::jsonb")
      add :name, :text, null: false
      add :slack_id, :text, null: false

      add :account_id, references(:accounts, on_delete: :delete_all, type: :binary_id), null: false
      add :team_id, references(:teams, on_delete: :delete_all, type: :binary_id,), null: false

      add :inserted_at, :timestamptz, null: false
      add :updated_at, :timestamptz, null: false
    end

    create index(:users, [:account_id, :team_id], unique: true)
    create index(:users, [:slack_id, :team_id], unique: true)
  end
end
