defmodule CanvasAPI.TeamView do
  use CanvasAPI.Web, :view

  alias CanvasAPI.UserView
  alias CanvasAPI.Team

  def render("index.json", %{teams: teams}) do
    %{
      data: render_many(teams, __MODULE__, "team.json"),
      included: Enum.map(teams, &include_account_user/1) |> Enum.filter(& &1)
    }
  end

  def render("show.json", %{team: team}) do
    %{
      data: render_one(team, __MODULE__, "team.json"),
      included: [include_account_user(team)] |> Enum.filter(& &1)
    }
  end

  def render("team.json", %{team: team}) do
    user = Map.get(team, :account_user)

    %{
      id: team.id,
      attributes: %{
        domain: team.domain,
        needs_slack_token: needs_slack_token(team),
        is_in_team: user != nil,
        images: (if user, do: team.images, else: %{}),
        name: (if user, do: team.name, else: nil),
        slack_scopes: slack_scopes(team),
        slack_id: (if user, do: team.slack_id, else: nil),
        inserted_at: team.inserted_at,
        updated_at: team.updated_at
      },
      relationships: relationships(team, user),
      type: "team"
    }
  end

  defp slack_scopes(team) do
    team.oauth_tokens
    |> Enum.find(&(&1.provider == "slack"))
    |> case do
      nil -> []
      token -> token.meta["scopes"] || []
    end
  end

  defp relationships(team, user) do
    %{
      canvases: %{
        links: %{
          related: team_canvas_path(CanvasAPI.Endpoint, :index, team.id)
        }
      },
      channels: %{
        links: %{
          related: team_channel_path(CanvasAPI.Endpoint, :index, team.id)
        }
      }
    }
    |> Map.put_new_lazy(:user, fn ->
         if user do
            %{
              data: %{
                id: user.id, type: "user"
              },
              links: %{
                related: team_user_path(CanvasAPI.Endpoint, :show, team.id)
              }
            }
         else
           nil
         end
       end)
  end

  defp include_account_user(%{account_user: nil}), do: nil
  defp include_account_user(team = %{account_user: user}) do
    render_one(Map.put(user, :team, team), UserView, "user.json")
  end

  defp needs_slack_token(%Team{slack_id: nil}), do: false
  defp needs_slack_token(team), do: !Enum.any?(team.oauth_tokens)
end
