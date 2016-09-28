defmodule CanvasAPI.Repo.Migrations.CreateOAuthToken do
  use Ecto.Migration

  def change do
    create table(:oauth_tokens, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :token, :string, null: false
      add :provider, :string, null: false
      add :meta, :map, null: false, default: fragment("'{}'::jsonb")

      add :account_id, references(:accounts, on_delete: :delete_all, type: :binary_id), null: false

      add :inserted_at, :timestamptz, null: false
      add :updated_at, :timestamptz, null: false
    end

    create index(:oauth_tokens, [:account_id])
    create unique_index(:oauth_tokens, [:account_id, :provider])
  end
end
