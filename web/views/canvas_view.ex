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
        native_version: canvas.native_version,
        type: canvas.type,
        version: canvas.version,
        inserted_at: canvas.inserted_at,
        updated_at: canvas.updated_at
      },
      type: "canvases"
    }
  end
end
