defmodule CanvasAPI.SlackTrackbackTest do
  use CanvasAPI.ModelCase

  alias CanvasAPI.{Canvas, SlackTrackback}

  import CanvasAPI.Factory
  import Mock

  test ".add/2 adds an event for a Slack channel message" do
    with_mock Slack.Channel, [info: &mock_info/2] do
      canvas = insert(:canvas)
      team = canvas.team
      insert(:oauth_token, team: canvas.team, provider: "slack")

      {:ok, event} = SlackTrackback.add(%{
        "channel" => "channel",
        "ts" => "0000.0000",
        "text" => "Slack message #{Canvas.web_url(canvas)}",
        "user" => canvas.creator.slack_id
      }, team.slack_id)

      assert event.url ==
        "https://#{team.domain}.slack.com/archives/channel-name/p00000000"
      assert event.type == "mentioned"
      assert event.canvas.id == canvas.id
      assert event.referencer.id == canvas.creator.id
    end
  end

  defp mock_info(_client, channel: _channel_id) do
    {:ok, %{"channel" =>%{"name" => "channel-name"}}}
  end
end
