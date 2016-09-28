defmodule CanvasAPI.Repo.Migrations.RemoveUniqueIndexFromOauthTokens do
  use Ecto.Migration

  def change do
    drop unique_index(:oauth_tokens, [:account_id, :provider])
  end
end
