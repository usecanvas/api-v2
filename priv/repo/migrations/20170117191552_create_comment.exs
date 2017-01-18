defmodule CanvasAPI.Repo.Migrations.CreateComment do
  use Ecto.Migration

  def change do
    create table(:comments, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :blocks, :jsonb, null: false, default: fragment("'[]'::jsonb")
      add :creator_id, references(:users, on_delete: :delete_all, type: :binary_id), null: false
      add :canvas_id, references(:canvases, on_delete: :delete_all, type: :string), null: false
      add :block_id, :string, null: false

      add :inserted_at, :timestamptz, null: false
      add :updated_at, :timestamptz, null: false
    end

    create index(:comments, [:canvas_id])
  end
end
