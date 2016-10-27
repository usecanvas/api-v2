defmodule CanvasAPI.Repo.Migrations.AddLinkAccessToCanvas do
  use Ecto.Migration

  def change do
    alter table(:canvases) do
      add :link_access, :text, null: false, default: "none"
    end
  end
end
