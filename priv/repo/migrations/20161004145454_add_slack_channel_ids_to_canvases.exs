defmodule CanvasAPI.Repo.Migrations.AddSlackChannelIdsToCanvases do
  use Ecto.Migration

  def change do
    alter table(:canvases) do
      add :slack_channel_ids, :jsonb, default: fragment("'[]'::jsonb")
    end
  end
end
