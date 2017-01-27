defmodule CanvasAPI.OpView do
  use CanvasAPI.Web, :view

  alias CanvasAPI.Endpoint

  def render("index.json", %{ops: ops}) do
    %{
      data: render_many(ops, __MODULE__, "op.json")
    }
  end

  def render("op.json", %{op: op}) do
    %{
      id: op.version,
      attributes: %{
        components: op.components,
        version: op.version,
        inserted_at: op.inserted_at,
        updated_at: op.updated_at
      },
      relationships: %{
        canvas: %{
          data: %{id: op.canvas.id, type: "canvas"},
          links: %{
            related: team_canvas_path(
              Endpoint, :show, op.canvas.team_id, op.canvas.id)
          }
        }
      },
      type: "op"
    }
  end
end
