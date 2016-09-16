defmodule CanvasAPI.Repo.Migrations.CreateTeam do
  use Ecto.Migration

  def change do
    create table(:teams, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :domain, :text, null: false
      add :images, :jsonb, null: false, default: fragment("'{}'::jsonb")
      add :name, :text, null: false
      add :slack_id, :text, null: false

      add :inserted_at, :timestamptz, null: false
      add :updated_at, :timestamptz, null: false
    end

    create index(:teams, [:domain], unique: true)
    create index(:teams, [:slack_id], unique: true)
  end
end
