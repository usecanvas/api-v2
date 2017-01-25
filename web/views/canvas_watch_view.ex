defmodule CanvasAPI.CanvasWatchView do
  @moduledoc """
  A view for rendering canvas watches.
  """

  alias CanvasAPI.Endpoint
  use CanvasAPI.Web, :view

  def render("index.json", %{canvas_watches: canvas_watches}) do
    %{
      data: render_many(canvas_watches, __MODULE__, "canvas_watch.json")
    }
  end

  def render("show.json", %{canvas_watch: canvas_watch}) do
    %{
      data: render_one(canvas_watch, __MODULE__, "canvas_watch.json")
    }
  end

  def render("canvas_watch.json", %{canvas_watch: canvas_watch}) do
    %{
      id: canvas_watch.canvas_id,
      attributes: %{
      },
      relationships: %{
        canvas: %{
          data: %{id: canvas_watch.canvas_id, type: "canvas"},
          links: %{
            related: team_canvas_path(Endpoint, :show,
                                      canvas_watch.canvas.team_id,
                                      canvas_watch.canvas.id)
          }
        },
        user: %{data: %{id: canvas_watch.user_id, type: "user"}}
      },
      type: "watched-canvas"
    }
  end
end

