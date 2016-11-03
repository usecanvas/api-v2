defmodule CanvasAPI.Repo.Migrations.RemoveSlackIdConstraintFromTeam do
  use Ecto.Migration

  def up do
    alter table(:teams) do
      modify :slack_id, :text, null: true
    end
  end

  def down do
    alter table(:teams) do
      modify :slack_id, :text, null: false
    end
  end
end
