defmodule CanvasAPI.Repo.Migrations.AddIsTemplateToCanvases do
  use Ecto.Migration

  def change do
    alter table(:canvases) do
      add :is_template, :boolean, default: false
    end
  end
end
