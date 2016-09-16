defmodule CanvasAPI.Repo.Migrations.AddImageUrlToAccounts do
  use Ecto.Migration

  def change do
    alter table(:accounts) do
      add :image_url, :string, null: false
    end
  end
end
