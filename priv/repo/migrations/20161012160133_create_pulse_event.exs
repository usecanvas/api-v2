defmodule CanvasAPI.Repo.Migrations.CreatePulseEvent do
  use Ecto.Migration

  def change do
    create table(:pulse_events, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :provider_name, :text, null: false
      add :provider_url, :text, null: false
      add :referencer, :jsonb, null: false
      add :type, :text, null: false
      add :url, :text, null: false

      add :canvas_id, references(:canvases, on_delete: :delete_all, type: :text), null: false

      add :inserted_at, :timestamptz, null: false
      add :updated_at, :timestamptz, null: false
    end

    create index(:pulse_events, [:canvas_id])
  end
end
