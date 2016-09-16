defmodule CanvasAPI.Repo.Migrations.AddImageUrlToTeams do
  use Ecto.Migration

  def change do
    alter table(:teams) do
      add :image_url, :string, null: false
    end
  end
end
