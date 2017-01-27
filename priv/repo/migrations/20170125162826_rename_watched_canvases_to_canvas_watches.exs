defmodule CanvasAPI.Repo.Migrations.RenameWatchedCanvasesToCanvasWatches do
  use Ecto.Migration

  def change do
    rename table(:watched_canvases), to: table(:canvas_watches)
  end
end
