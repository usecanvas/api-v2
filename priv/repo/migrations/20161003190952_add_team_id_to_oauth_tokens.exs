defmodule CanvasAPI.Repo.Migrations.AddTeamIdToOauthTokens do
  use Ecto.Migration

  def up do
    alter table(:oauth_tokens) do
      modify :account_id, :binary_id, null: true
      add :team_id, references(:teams, on_delete: :delete_all, type: :binary_id)
    end

    create index(:oauth_tokens, [:team_id])
    create unique_index(:oauth_tokens, [:team_id, :provider])
  end

  def down do
    alter table(:oauth_tokens) do
      modify :account_id, :binary_id, null: false
      remove :team_id
    end
  end
end
