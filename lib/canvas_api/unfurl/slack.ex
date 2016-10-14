defmodule CanvasAPI.Unfurl.Slack do
  @moduledoc """
  An unfurled Slack item.
  """

  @provider_name "Slack"
  @provider_url "https://slack.com"
  @provider_icon_url(
    "https://s3.amazonaws.com/canvas-assets/provider-icons/slack.png")

  def unfurl(url, account: account) do
    with mod when is_atom(mod) <- get_unfurl_mod(url),
         unfurl when not is_nil(unfurl) <- mod.unfurl(url, account: account) do
      %CanvasAPI.Unfurl{
        unfurl |
          id: url,
          provider_name: @provider_name,
          provider_url: @provider_url,
          provider_icon_url: @provider_icon_url,
          url: url
      }
    end
  end

  defp get_unfurl_mod(url) do
    if is_channel_message?(url) do
      CanvasAPI.Unfurl.Slack.ChannelMessage
    else
      CanvasAPI.Unfurl.Embedly
    end
  end

  defp is_channel_message?(url) do
    Regex.match?(CanvasAPI.Unfurl.Slack.ChannelMessage.match, url)
  end
end
