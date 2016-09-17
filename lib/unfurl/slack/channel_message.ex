defmodule CanvasAPI.Unfurl.Slack.ChannelMessage do
  @match ~r|\Ahttps://[^\.]+\.slack\.com/archives/(?<channel>[^/]+)/p(?<timestamp>\d+)\z|
  @slack System.get_env("SLACK_API_TOKEN") |> Slack.client

  def match, do: @match

  def unfurl(url) do
    with response when is_map(response) <- do_request(parse_url(url)) do
      %CanvasAPI.Unfurl{
        id: url,
        title: "Message from @#{response[:user]["name"]}",
        text: response[:message]["text"],
        thumbnail_url: response[:user]["profile"]["image_original"]
      }
    end
  end

  defp do_request(%{channel: name, timestamp: timestamp}) do
    with {:ok, %{"channels" => channels}} <- get_channels,
         channel when not is_nil(channel) <- find_channel(channels, name),
         {:ok, %{"messages" => [message]}} <- get_message(channel, timestamp),
         {:ok, %{"user" => user}} <- get_user(message["user"]) do
      %{channel: channel, message: message, user: user}
    end
  end

  defp get_channels do
    Slack.Channel.list(@slack)
  end

  defp get_message(channel, timestamp) do
    Slack.Channel.history(@slack,
      channel: channel["id"], oldest: timestamp, inclusive: 1, count: 1)
  end

  defp get_user(user_id) do
    Slack.User.info(@slack, user: user_id)
  end

  defp find_channel(channels, name) do
    channels
    |> Enum.find(fn channel -> channel["name"] == name end)
  end

  defp parse_url(url) do
    %{"channel" => channel, "timestamp" => timestamp} =
      Regex.named_captures(@match, url)
    %{channel: channel, timestamp: parse_timestamp(timestamp)}
  end

  defp parse_timestamp(timestamp) do
    String.split_at(timestamp, -6) |> Tuple.to_list |> Enum.join(".")
  end
end
