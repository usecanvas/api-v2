defmodule CanvasAPI.SlackTrackback do
  @moduledoc """
  A reference of a canvas in Slack.
  """

  alias CanvasAPI.{Canvas, OAuthToken, PulseEvent, Repo, Team, User}
  import Ecto.Changeset, only: [put_assoc: 3]
  import Ecto.Query, only: [from: 2]
  import Ecto, only: [assoc: 2]

  @canvas_regex Regex.compile!(
    "#{System.get_env("WEB_URL")}/[^/]+/(?<id>[^/]{22})")

  @doc """
  Add a slack trackback to a canvas.

  TODO: This only tracks the first canvas mentioned in the message.
  """
  @spec add(map, String.t) :: {:ok, %PulseEvent{}} |
                              {:error, Ecto.Changeset.t} |
                              nil
  def add(%{
    "channel" => channel_id,
    "ts" => message_ts,
    "text" => text,
    "user" => user_id},
    team_id) do
    with canvas = %Canvas{} <- get_canvas(text),
         team = %Team{} <- get_team(team_id),
         user = %User{} <- get_user(team, user_id),
         token = %OAuthToken{} <- Team.get_token(team, "slack"),
         bot_token = get_in(token.meta, ~w(bot bot_access_token)) do
      %PulseEvent{}
      |> PulseEvent.changeset(%{
           provider_name: "Slack",
           provider_url: "https://slack.com",
           type: "mentioned",
           url: message_url(team.domain, channel_id, message_ts, bot_token),
           referencer: %{
             id: user.id,
             avatar_url: AvatarURL.create(user.email),
             email: user.email,
             name: user.name,
             url: "mailto:#{user.email}"
           }})
      |> put_assoc(:canvas, canvas)
      |> Repo.insert!
    end
  end

  defp get_canvas(text) do
    with match when match != nil <- Regex.named_captures(@canvas_regex, text) do
      Repo.get(Canvas, match["id"])
    end
  end

  defp get_team(team_id) do
    from(Team, where: [slack_id: ^team_id]) |> Repo.one
  end

  defp get_user(team, user_id) do
    from(assoc(team, :users), where: [slack_id: ^user_id]) |> Repo.one
  end

  defp message_url(domain, channel_id, message_ts, bot_token) do
    with client = Slack.client(bot_token),
         {:ok, %{"channel" => channel}}
           <- Slack.Channel.info(client, channel_id),
         message_id = "p" <> String.replace(message_ts, ".", "") do
      "https://#{domain}.slack.com/archives/#{channel["name"]}/#{message_id}"
    end
  end
end
