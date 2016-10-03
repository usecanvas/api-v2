defmodule CanvasAPI.Slack.ChannelController do
  use CanvasAPI.Web, :controller

  alias CanvasAPI.{Canvas, ChangesetView, ErrorView, Repo, Team, User}

  plug CanvasAPI.CurrentAccountPlug
  plug :ensure_team
  plug :ensure_user

  def index(conn, params) do
    with token <- get_slack_token(conn),
         channels <- get_slack_channels(token) do
      render(conn, "index.json", channels: channels)
    end
  end

  defp get_slack_channels(token) do
    token
    |> Slack.client
    |> Slack.Channel.list(exclude_archived: 1)
    |> elem(1)
    |> Map.get("channels")
    |> Enum.sort_by(&(&1["name"]))
  end

  defp get_slack_token(conn) do
    from(assoc(conn.private.current_team, :oauth_tokens),
         where: [provider: "slack"])
    |> Repo.one
    |> Map.get(:token)
  end
end
