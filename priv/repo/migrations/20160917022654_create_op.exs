defmodule CanvasAPI.Repo.Migrations.CreateOp do
  use Ecto.Migration

  def change do
    create table(:ops, primary_key: false) do
      add :components, :jsonb, null: false
      add :meta, :jsonb, null: false
      add :seq, :integer, null: false
      add :source, :text, null: false
      add :version, :integer, null: false

      add :canvas_id, references(:canvases, on_delete: :delete_all, type: :text), null: false

      add :inserted_at, :timestamptz, null: false
      add :updated_at, :timestamptz, null: false
    end

    create index(:ops, [:canvas_id, :version], unique: true)
  end
end
