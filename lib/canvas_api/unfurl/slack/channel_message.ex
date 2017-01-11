defmodule CanvasAPI.Unfurl.Slack.ChannelMessage do
  @moduledoc """
  An unfurls Slack channel message.

  This module receives a URL pointing to a Slack Channel message and parses it
  into an Unfurl struct. It makes a reasonable attempt at parsing usernames
  and other such data into human-readable forms, but will sometimes leave bare
  Slack "syntax" in the message.
  """

  @match Regex.compile!("""
  \\A
  https://(?<domain>[^\\.]+)\\.slack\\.com
  /archives
  /(?<channel>[^/]+)
  /p(?<timestamp>\\d+)
  \\z
  """, "x")

  @channel_history_length 50

  alias CanvasAPI.{SlackParser, Team, TeamService, Unfurl}

  def match, do: @match

  @doc """
  Unfurl a Slack channel message URL into an Unfurl struct.
  """
  @spec unfurl(String.t, Keyword.t) :: Unfurl.t | nil
  def unfurl(url, account: account) do
    {domain, channel, message_id} = parse_url(url)

    with {:ok, team}  <- TeamService.show(domain, account: account),
         {:ok, %{token: token}} <- Team.get_token(team, "slack"),
         {:ok, message_info} <- get_message_info(token, channel, message_id) do
      %Unfurl{
        id: url,
        title: "Message from @#{message_info[:user]["name"]}",
        text: message_info[:message],
        thumbnail_url: message_info[:user]["profile"]["image_original"],
        attachments: message_info[:attachments]}
    else
        {:error, %HTTPoison.Response{}} ->
          failed_fetch(url)
        {:error, :token_not_found} ->
          failed_fetch(url)
        _ ->
          nil
    end
  end

  @spec build_attachments([map], Keyword.t) :: [map]
  defp build_attachments(messages, user: user, users: users) do
    messages
    |> Enum.filter(&(&1["user"] && &1["text"])) # Only messages w/user + text
    |> Enum.reverse # Oldest first
    |> Enum.map(fn message ->
      %{author: "@#{user["name"]}",
        timestamp: message["ts"],
        text: parse_message(message, users: users),
        thumbnail_url: get_in(user, ~w(profile image_original))}
    end)
  end

  @spec failed_fetch(String.t) :: Unfurl.t
  defp failed_fetch(url) do
    %Unfurl{
      id: url,
      title: url,
      text: nil,
      thumbnail_url: nil,
      fetched: false
    }
  end

  @spec find_channel(Slack.Client.t, String.t) :: {:ok, map} | {:error, any}
  defp find_channel(client, channel_name) do
    with {:ok, %{"channels" => channels}} <- Slack.Channel.list(client) do
      channels
      |> Enum.find(&(&1["name"] == channel_name))
      |> case do
        channel when is_map(channel) ->
          {:ok, channel}
        nil ->
          {:error, :channel_not_found}
      end
    end
  end

  @spec get_channel_history(Slack.Client.t, map, String.t) :: {:ok, map}
                                                            | {:error, any}
  defp get_channel_history(client, channel, message_id) do
    Slack.Channel.history(
      client,
      channel: channel["id"],
      oldest: message_id,
      inclusive: 1,
      count: @channel_history_length)
  end

  @spec get_message_info(String.t, String.t, String.t) :: {:ok, map}
                                                        | {:error, any}
  defp get_message_info(token, channel_name, message_id) do
    with client = Slack.client(token),
         {:ok, channel} <- find_channel(client, channel_name),
         {:ok, %{"members" => users}} <- Slack.User.list(client),
         {:ok, %{"messages" => messages}} <-
           get_channel_history(client, channel, message_id),
         message = List.last(messages),
         {:ok, user} <- get_user(users, message["user"]) do

      message_info = %{
        channel: channel,
        message: parse_message(message, users: users),
        attachments: build_attachments(messages, user: user, users: users),
        user: user}

      {:ok, message_info}
    end
  end

  @spec get_user([map], String.t) :: {:ok, map} | {:error, :user_not_found}
  defp get_user(users, user_id) do
    users
    |> Enum.find(&(&1["id"] == user_id))
    |> case do
      user when is_map(user) ->
        {:ok, user}
      nil ->
        {:error, :user_not_found}
    end
  end

  @spec parse_message(map, Keyword.t) :: map
  defp parse_message(message, users: users) do
    message["text"]
    |> SlackParser.to_text
    |> SlackParser.username_replace(users)
  end

  @spec parse_url(String.t) :: {String.t, String.t, String.t}
  defp parse_url(url) do
    matches = Regex.named_captures(@match, url)

    {matches["domain"],
     matches["channel"],
     timestamp_to_message_id(matches["timestamp"])}
  end

  @spec timestamp_to_message_id(String.t) :: String.t
  defp timestamp_to_message_id(timestamp) do
    timestamp
    |> String.split_at(-6)
    |> Tuple.to_list
    |> Enum.join(".")
  end
end
