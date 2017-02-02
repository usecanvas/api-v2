defmodule CanvasAPI.Repo.Migrations.CreateThreadSubscription do
  use Ecto.Migration

  def change do
    create table(:thread_subscriptions, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :block_id, :text, null: false
      add :subscribed, :boolean, default: false, null: false
      add :canvas_id, references(:canvases, on_delete: :delete_all, type: :text), null: false
      add :user_id, references(:users, on_delete: :delete_all, type: :binary_id), null: false
      add :inserted_at, :timestamptz, null: false
      add :updated_at, :timestamptz, null: false
    end

    create unique_index(:thread_subscriptions, [:user_id, :canvas_id, :block_id])
  end
end
