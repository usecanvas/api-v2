defmodule CanvasAPI.Repo.Migrations.RemoveSlackIdAndIdentityTokenConstraintsFromUser do
  use Ecto.Migration

  use Ecto.Migration

  def up do
    alter table(:users) do
      modify :slack_id, :text, null: true
      modify :identity_token, :text, null: true
    end
  end

  def down do
    alter table(:users) do
      modify :slack_id, :text, null: false
      modify :identity_token, :text, null: false
    end
  end
end
