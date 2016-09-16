defmodule CanvasAPI.Repo.Migrations.AddUserFieldsToMemberships do
  use Ecto.Migration

  def change do
    alter table(:memberships) do
      add :name, :string, null: false
      add :email, :citext, null: false
      add :slack_id, :string, null: false
      add :image_url, :string, null: false
    end

    create index(:memberships, [:slack_id, :team_id], unique: true)

    alter table(:accounts) do
      remove :name
      remove :email
      remove :slack_id
      remove :image_url
    end
  end

  def down do
    alter table(:memberships) do
      remove :name
      remove :email
      remove :slack_id
      remove :image_url
    end

    alter table(:accounts) do
      add :name, :string, null: false
      add :email, :citext, null: false
      add :slack_id, :string, null: false
      add :image_url, :string, null: false
    end
  end
end
