defmodule CanvasAPI.Unfurl.Slack.ChannelMessageTest do
  use CanvasAPI.ModelCase

  alias CanvasAPI.Unfurl
  alias CanvasAPI.Unfurl.Slack.ChannelMessage, as: UnfurlMessage

  import CanvasAPI.Factory
  import Mock

  setup do
    user = insert(:user)
    insert(:oauth_token, account: nil, team: user.team, provider: "slack")
    {:ok, user: user}
  end

  test "unfurls a Slack channel message", %{user: user} do
    url = "https://#{user.team.domain}.slack.com/archives/general/p00000000"

    with_mocks([
      {Slack.Channel, [], [list: &mock_list/1, history: mock_history(user)]},
      {Slack.User, [], [info: &mock_info/2, list: mock_user_list(user)]}
    ]) do
      unfurl = UnfurlMessage.unfurl(url, account: user.account)
      assert unfurl ==
        %Unfurl{
          id: url,
          attachments: [%{
            author: "@user",
            text: "Message Content",
            thumbnail_url: "thumbnail",
            timestamp: nil
          }],
          title: "Message from @user",
          text: "Message Content",
          thumbnail_url: "thumbnail"}
    end
  end

  defp mock_list(_client) do
    {:ok,
     %{"channels" => [%{"name" => "general", "id" => "channel_id"}]
       }}
  end

  defp mock_history(user) do
    fn _client, _opts ->
      {:ok,
       %{"messages" => [
         %{"user" => user.slack_id,
           "text" => "Message Content"}]}}
    end
  end

  defp mock_info(_client, opts) do
    {:ok,
     %{"user" => %{
       "id" => opts[:user],
       "name" => "user",
       "profile" => %{"image_original" => "thumbnail"}}}}
  end

  defp mock_user_list(user) do
    fn _client ->
      {:ok,
       %{"members" => [%{
         "id" => user.slack_id,
         "name" => "user",
         "profile" => %{"image_original" => "thumbnail"}}]}}
    end
  end
end
