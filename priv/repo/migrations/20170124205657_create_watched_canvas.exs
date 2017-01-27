defmodule CanvasAPI.Repo.Migrations.CreateWatchedCanvas do
  use Ecto.Migration

  def change do
    create table(:watched_canvases, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :canvas_id, references(:canvases, on_delete: :delete_all, type: :text)
      add :user_id, references(:users, on_delete: :delete_all, type: :binary_id)

      add :inserted_at, :timestamptz, null: false
      add :updated_at, :timestamptz, null: false
    end

    create index(:watched_canvases, [:canvas_id])
    create index(:watched_canvases, [:user_id])
  end
end
