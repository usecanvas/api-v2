defmodule CanvasAPI.SlackTrackback do
  @moduledoc """
  A reference of a canvas in Slack.
  """

  use CanvasAPI.Trackback

  @doc """
  Add a slack trackback to a canvas.

  TODO: This only tracks the first canvas mentioned in the message.
  """
  def add(%{
    "channel" => channel_id,
    "ts" => message_ts,
    "text" => text,
    "user" => user_id},
    team_id) do
    with canvas = %Canvas{} <- get_canvas(text),
         team = %Team{} <- get_team(team_id),
         user = %User{} <- get_user(team, user_id),
         {:ok, token} <- Team.get_token(team, "slack") do
      PulseEventService.create(
        %{provider_name: "Slack",
          provider_url: "https://slack.com",
          type: "mentioned",
          url: message_url(team.domain, channel_id, message_ts, token.token),
          referencer: %{
            id: user.id,
            avatar_url: AvatarURL.create(user.email),
            email: user.email,
            name: user.name,
            url: "mailto:#{user.email}"
           }},
        canvas: canvas)
    end
  end

  def add(_, _), do: nil

  defp get_team(team_id) do
    from(Team, where: [slack_id: ^team_id]) |> Repo.one
  end

  defp message_url(domain, channel_id, message_ts, token) do
    with client = Slack.client(token),
         {:ok, %{"channel" => channel}}
           <- Slack.Channel.info(client, channel: channel_id),
         message_id = "p" <> String.replace(message_ts, ".", "") do
      "https://#{domain}.slack.com/archives/#{channel["name"]}/#{message_id}"
    end
  end
end
