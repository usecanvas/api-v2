defmodule CanvasAPI.Repo.Migrations.AddEditedAtToCanvases do
  use Ecto.Migration

  def up do
    alter table(:canvases) do
      add :edited_at, :timestamptz
    end

    execute """
    UPDATE canvases SET edited_at = updated_at
    """
  end

  def down do
    alter table(:canvases) do
      remove :edited_at
    end
  end
end
