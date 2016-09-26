defmodule CanvasAPI.Repo.Migrations.CreateWhitelistedSlackDomain do
  use Ecto.Migration

  def change do
    create table(:whitelisted_slack_domains, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :domain, :string

      add :inserted_at, :timestamptz, null: false
      add :updated_at, :timestamptz, null: false
    end

    create unique_index(:whitelisted_slack_domains, [:domain])
  end
end
