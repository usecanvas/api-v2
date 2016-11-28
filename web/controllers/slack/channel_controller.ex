defmodule CanvasAPI.Slack.ChannelController do
  use CanvasAPI.Web, :controller

  alias CanvasAPI.{Repo, Team}

  plug CanvasAPI.CurrentAccountPlug
  plug :ensure_team
  plug :ensure_user

  def index(conn, _params) do
    with token <- get_slack_token(conn),
         {:ok, channels} <- get_channels(token, conn.private.current_team) do
      render(conn, "index.json", channels: channels)
    else
      {:error, detail} ->
        bad_request(conn, detail: detail)
    end
  end

  defp get_channels(nil, %Team{slack_id: nil}), do: {:ok, []}

  defp get_channels(token, team) do
    token
    |> Slack.client
    |> Slack.Channel.list(exclude_archived: 1)
    |> case do
      {:ok, response} ->
        {:ok, process_channels(response["channels"], team)}
      {:error, %HTTPoison.Response{body: %{"error" => "token_revoked"}}} ->
        {:error, gettext("Slack token revoked")}
      {:error, _} ->
        {:error, nil}
    end
  end

  defp get_slack_token(conn) do
    from(assoc(conn.private.current_team, :oauth_tokens),
         where: [provider: "slack"])
    |> Repo.one
    |> case do
      nil -> nil
      token -> Map.get(token, :token)
    end
  end

  defp process_channels(channels, team) do
    channels
    |> Enum.map(& Map.put(&1, "team", team))
    |> Enum.sort_by(& &1["name"])
  end
end
