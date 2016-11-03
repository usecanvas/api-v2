defmodule CanvasAPI.Repo.Migrations.RemoveNullConstraintFromTeamDomain do
  use Ecto.Migration

  def up do
    alter table(:teams) do
      modify :domain, :text, null: true
    end
  end

  def down do
    alter table(:teams) do
      modify :domain, :text, null: false
    end
  end
end
