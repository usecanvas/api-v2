defmodule CanvasAPI.Unfurl.Slack do
  def unfurl(url) do
    with mod when is_atom(mod) <- get_unfurl_mod(url),
         unfurl when not is_nil(unfurl) <- mod.unfurl(url) do
      %CanvasAPI.Unfurl{
        unfurl |
          provider_name: "Slack",
          provider_url: "https://slack.com",
          provider_icon_url: "https://s3.amazonaws.com/canvas-assets/provider-icons/slack.png"
      }
    end
  end

  defp get_unfurl_mod(url) do
    cond do
      is_channel_message?(url) -> CanvasAPI.Unfurl.Slack.ChannelMessage
      true -> CanvasAPI.Unfurl.OpenGraph
    end
  end

  defp is_channel_message?(url) do
    Regex.match?(CanvasAPI.Unfurl.Slack.ChannelMessage.match, url)
  end
end
