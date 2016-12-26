defmodule CanvasAPI.Repo.Migrations.CreatePersonalAccessToken do
  use Ecto.Migration

  def change do
    create table(:personal_access_tokens, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :token, :text, null: false
      add :account_id, references(:accounts, on_delete: :nothing, type: :binary_id), null: false

      add :inserted_at, :timestamptz, null: false
      add :updated_at, :timestamptz, null: false
    end

    create index(:personal_access_tokens, [:account_id])
  end
end
