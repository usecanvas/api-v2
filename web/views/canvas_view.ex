defmodule CanvasAPI.CanvasView do
  use CanvasAPI.Web, :view

  def render("index.json", %{canvases: canvases}) do
    %{data: render_many(canvases, CanvasAPI.CanvasView, "canvas.json")}
  end

  def render("show.json", %{canvas: canvas}) do
    %{data: render_one(canvas, CanvasAPI.CanvasView, "canvas.json")}
  end

  def render("canvas.json", %{canvas: canvas}) do
    %{
      id: canvas.id,
      attributes: %{
        blocks: canvas.blocks,
        is_template: canvas.is_template,
        native_version: canvas.native_version,
        type: canvas.type,
        version: canvas.version,
        inserted_at: canvas.inserted_at,
        updated_at: canvas.updated_at
      },
      relationships: %{
        team: %{
          data: %{
            id: canvas.team_id, type: "teams"
          },
          links: %{
            related: team_path(CanvasAPI.Endpoint, :show, canvas.team_id)
          }
        }
      },
      type: "canvas"
    }
  end
end
