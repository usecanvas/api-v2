defmodule CanvasAPI.Slack.ChannelView do
  use CanvasAPI.Web, :view

  def render("index.json", %{channels: channels}) do
    %{data: render_many(channels, CanvasAPI.Slack.ChannelView, "channel.json")}
  end

  def render("show.json", %{channel: channel}) do
    %{data: render_one(channel, CanvasAPI.Slack.ChannelView, "channel.json")}
  end

  def render("channel.json", %{channel: channel}) do
    %{
      id: channel["id"],
      attributes: %{
        name: channel["name"],
        topic: channel_topic(channel)
      },
      relationships: %{
        team: %{
          data: %{id: channel["team"].id, type: "team"},
          links: %{
            related: team_path(CanvasAPI.Endpoint, :show, channel["team"].id)
          }
        }
      },
      type: "slack-channel"
    }
  end

  defp channel_topic(%{"topic" => %{"value" => ""}}), do: nil
  defp channel_topic(%{"topic" => %{"value" => value}}), do: value
end
