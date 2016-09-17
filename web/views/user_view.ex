defmodule CanvasAPI.UserView do
  use CanvasAPI.Web, :view

  def render("show.json", %{user: user}) do
    %{data: render_one(user, CanvasAPI.UserView, "user.json")}
  end

  def render("user.json", %{user: user}) do
    %{
      id: user.id,
      attributes: %{
        email: user.email,
        images: user.images,
        name: user.name,
        slack_id: user.slack_id,
        inserted_at: user.inserted_at,
        updated_at: user.updated_at
      },
      relationships: %{
        canvases: %{
          links: %{
            related: team_canvas_path(CanvasAPI.Endpoint, :index, user.team.id)
          }
        },
        team: %{
          data: %{
            id: user.team.id, type: "teams"
          },
          links: %{
            related: team_path(CanvasAPI.Endpoint, :show, user.team.id),
          }
        }
      },
      type: "user"
    }
  end
end
