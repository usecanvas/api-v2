defmodule CanvasAPI.Unfurl.Slack.ChannelMessage do
  @moduledoc """
  An unfurled Slack channel message.
  """

  @lint {Credo.Check.Readability.MaxLineLength, false}
  @match ~r|\Ahttps://(?<domain>[^\.]+)\.slack\.com/archives/(?<channel>[^/]+)/p(?<timestamp>\d+)\z|

  @history_length 50

  alias CanvasAPI.{OAuthToken, Repo, SlackParser, Team, Unfurl}
  alias Slack.{Channel, User}

  import Ecto.Query, only: [from: 2]
  import Ecto, only: [assoc: 2]

  def match, do: @match

  @doc """
  Unfurl a Slack channel message URL by fetching the channel message and some
  length of history after it.
  """
  @spec unfurl(url::String.t, options::Keyword.t) :: Unfurl.t | nil
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
        text: response[:message],
        thumbnail_url: response[:user]["profile"]["image_original"],
        attachments: response[:attachments]
      }
    end
  end

  @spec do_request(String.t, String.t, String.t) :: map
  defp do_request(token, name, timestamp) do
    with client = Slack.client(token),
         {:ok, %{"channels" => channels}} <- get_channels(client),
         channel when not is_nil(channel) <- find_channel(channels, name),
         {:ok, %{"members" => users}} <- User.list(client),
         {:ok, %{"messages" => messages}} <-
           get_messages(client, channel, timestamp),
         message = List.last(messages),
         {:ok, user} <- get_user(users, message["user"]) do
      %{channel: channel,
        message: SlackParser.to_text(message["text"])
                 |> SlackParser.username_replace(users),
        attachments: make_attachments(messages, users),
        user: user}
    end
  end

  @spec make_attachments([map], [map]) :: [map]
  defp make_attachments(messages, users) do
    messages =
      messages
      |> Enum.filter(&(&1["user"] && &1["text"]))
      |> Enum.reverse

    messages
    |> Enum.map(fn message ->
      {:ok, user} = get_user(users, message["user"])

      %{
        author: "@#{user["name"]}",
        timestamp: message["ts"],
        text: SlackParser.to_text(message["text"])
              |> SlackParser.username_replace(users),
        thumbnail_url: user |> get_in(~w(profile image_original))
      }
    end)
  end

  @spec get_channels(Slack.Client.t) :: {:ok, map} | {:error, any}
  defp get_channels(client) do
    Channel.list(client)
  end

  @spec get_team(CanvasAPI.Account.t, String.t) :: CanvasAPI.Team.t | nil
  defp get_team(account, domain) do
    from(assoc(account, :teams), where: [domain: ^domain])
    |> Repo.one
  end

  @spec get_messages(Slack.Client.t, map, String.t) :: {:ok, map}
                                                     | {:error, any}
  defp get_messages(client, channel, timestamp) do
    Channel.history(client,
      channel: channel["id"],
      oldest: timestamp,
      inclusive: 1,
      count: @history_length)
  end

  @spec get_user([map], String.t) :: {:ok, map} | {:error, :not_found}
  defp get_user(users, user_id) do
    if user = Enum.find(users, &(&1["id"] == user_id)) do
      {:ok, user}
    else
      {:error, :not_found}
    end
  end

  @spec find_channel([map], String.t) :: map
  defp find_channel(channels, name) do
    channels
    |> Enum.find(fn channel -> channel["name"] == name end)
  end

  @spec parse_url(String.t) :: map
  defp parse_url(url) do
    %{"channel" => channel, "domain" => domain, "timestamp" => timestamp} =
      Regex.named_captures(@match, url)
    %{channel: channel, domain: domain, timestamp: parse_timestamp(timestamp)}
  end

  @spec parse_timestamp(String.t) :: String.t
  defp parse_timestamp(timestamp) do
    String.split_at(timestamp, -6) |> Tuple.to_list |> Enum.join(".")
  end
end
