defmodule CanvasAPI.Repo.Migrations.ChangeTemplateIdToString do
  use Ecto.Migration

  def up do
    alter table(:canvases) do
      modify :template_id, :string
    end
  end
end
