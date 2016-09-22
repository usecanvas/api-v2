defmodule CanvasAPI.Repo.Migrations.AddTemplateIdToCanvases do
  use Ecto.Migration

  def change do
    alter table(:canvases) do
      add :template_id, :binary_id # No reference so that stats aren't broken
    end
  end
end
