defmodule CanvasAPI.WatchedCanvasView do
  @moduledoc """
  A view for rendering watched_canvases.
  """

  alias CanvasAPI.Endpoint
  use CanvasAPI.Web, :view

  def render("index.json", %{watched_canvases: watched_canvases}) do
    %{
      data: render_many(watched_canvases, __MODULE__, "watched_canvas.json")
    }
  end

  def render("show.json", %{watched_canvas: watched_canvas}) do
    %{
      data: render_one(watched_canvas, __MODULE__, "watched_canvas.json")
    }
  end

  def render("watched_canvas.json", %{watched_canvas: watched_canvas}) do
    %{
      id: watched_canvas.canvas_id,
      attributes: %{
      },
      relationships: %{
        canvas: %{
          data: %{id: watched_canvas.canvas_id, type: "canvas"},
          links: %{
            related: team_canvas_path(Endpoint, :show,
                                      watched_canvas.canvas.team_id,
                                      watched_canvas.canvas.id)
          }
        },
        user: %{data: %{id: watched_canvas.user_id, type: "user"}}
      },
      type: "watched-canvas"
    }
  end
end

