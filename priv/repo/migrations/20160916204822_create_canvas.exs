defmodule CanvasAPI.Repo.Migrations.CreateCanvas do
  use Ecto.Migration

  def change do
    create table(:canvases, primary_key: false) do
      add :id, :text, primary_key: true

      add :blocks, :jsonb, null: false, default: fragment("'[]'::jsonb")
      add :native_version, :string, null: false
      add :type, :text, null: false
      add :version, :integer, null: false, default: 0

      add :creator_id, references(:accounts, on_delete: :delete_all, type: :binary_id), null: false
      add :team_id, references(:teams, on_delete: :delete_all, type: :binary_id), null: false

      add :inserted_at, :timestamptz, null: false
      add :updated_at, :timestamptz, null: false
    end
  end
end
