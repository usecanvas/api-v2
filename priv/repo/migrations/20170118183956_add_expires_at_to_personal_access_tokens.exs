defmodule CanvasAPI.Repo.Migrations.AddExpiresAtToPersonalAccessTokens do
  use Ecto.Migration

  def change do
    alter table(:personal_access_tokens) do
      add :expires_at, :bigint
    end
  end
end
