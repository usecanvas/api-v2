defmodule CanvasAPI.Unfurl.Slack.ChannelMessage do
  @moduledoc """
  An unfurled Slack channel message.
  """

  @lint {Credo.Check.Readability.MaxLineLength, false}
  @match ~r|\Ahttps://(?<domain>[^\.]+)\.slack\.com/archives/(?<channel>[^/]+)/p(?<timestamp>\d+)\z|

  alias CanvasAPI.{OAuthToken, Repo, Team, Unfurl}
  alias Slack.{Channel, User}

  import Ecto.Query, only: [from: 2]
  import Ecto, only: [assoc: 2]

  def match, do: @match

  def unfurl(url, account: account) do
    with %{channel: channel, domain: domain, timestamp: timestamp}
           <- parse_url(url),
         team = %Team{} <- get_team(account, domain),
         token = %OAuthToken{} <- Team.get_token(team, "slack"),
         response when response != nil <-
           do_request(token.token, channel, timestamp) do
      %Unfurl{
        id: url,
        title: "Message from @#{response[:user]["name"]}",
        text: response[:message]["text"],
        thumbnail_url: response[:user]["profile"]["image_original"]
      }
    end
  end

  defp do_request(token, name, timestamp) do
    with client = Slack.client(token),
         {:ok, %{"channels" => channels}} <- get_channels(client),
         channel when not is_nil(channel) <- find_channel(channels, name),
         {:ok, %{"messages" => [message]}} <-
           get_message(client, channel, timestamp),
         {:ok, %{"user" => user}} <- get_user(client, message["user"]) do
      %{channel: channel, message: message, user: user}
    end
  end

  defp get_channels(client) do
    Channel.list(client)
  end

  defp get_team(account, domain) do
    from(assoc(account, :teams), where: [domain: ^domain])
    |> Repo.one
  end

  defp get_message(client, channel, timestamp) do
    Channel.history(client,
      channel: channel["id"], oldest: timestamp, inclusive: 1, count: 1)
  end

  defp get_user(client, user_id) do
    User.info(client, user: user_id)
  end

  defp find_channel(channels, name) do
    channels
    |> Enum.find(fn channel -> channel["name"] == name end)
  end

  defp parse_url(url) do
    %{"channel" => channel, "domain" => domain, "timestamp" => timestamp} =
      Regex.named_captures(@match, url)
    %{channel: channel, domain: domain, timestamp: parse_timestamp(timestamp)}
  end

  defp parse_timestamp(timestamp) do
    String.split_at(timestamp, -6) |> Tuple.to_list |> Enum.join(".")
  end
end
