defmodule CanvasAPI.TeamView do
  use CanvasAPI.Web, :view

  def render("index.json", %{teams: teams}) do
    %{
      data: render_many(teams, CanvasAPI.TeamView, "team.json"),
      included: Enum.map(teams, fn team ->
        user = Enum.at(team.users, 0)
        render_one(Map.put(user, :team, team), CanvasAPI.UserView, "user.json")
      end)
    }
  end

  def render("show.json", %{team: team}) do
    user = Enum.at(team.users, 0)

    %{
      data: render_one(team, __MODULE__, "team.json"),
      included: [
        render_one(Map.put(user, :team, team), CanvasAPI.UserView, "user.json")
      ]
    }
  end

  def render("team.json", %{team: team}) do
    user = Enum.at(team.users, 0)

    %{
      id: team.id,
      attributes: %{
        domain: team.domain,
        has_slack_token: Enum.any?(team.oauth_tokens),
        images: team.images,
        name: team.name,
        slack_id: team.slack_id,
        inserted_at: team.inserted_at,
        updated_at: team.updated_at
      },
      relationships: %{
        canvases: %{
          links: %{
            related: team_canvas_path(CanvasAPI.Endpoint, :index, team.id)
          }
        },
        channels: %{
          links: %{
            related: team_channel_path(CanvasAPI.Endpoint, :index, team.id)
          }
        },
        user: %{
          data: %{
            id: user.id, type: "user"
          },
          links: %{
            related: team_user_path(CanvasAPI.Endpoint, :show, team.id)
          }
        }
      },
      type: "team"
    }
  end
end
