defmodule CanvasAPI.Unfurl.GitHub.PullRequestTest do
  use CanvasAPI.ModelCase

  alias CanvasAPI.{AvatarURL, Unfurl}
  alias CanvasAPI.Unfurl.{Field, Label}
  alias CanvasAPI.Unfurl.GitHub.PullRequest, as: UnfurlPullRequest
  alias CanvasAPI.Unfurl.GitHub.API, as: GitHubAPI

  import CanvasAPI.Factory
  import Mock

  setup do
    account = insert(:account)
    {:ok, account: account}
  end

  test "unfurls GitHub issue URLs", %{account: account} do
    with_mock GitHubAPI, [get_by: &mock_get_by/2] do
      url = "https://github.com/usecanvas/pro-web/pull/1"
      unfurl = UnfurlPullRequest.unfurl(url, account: account)
      assert unfurl == %Unfurl{
        id: url,
        title: "Title",
        text: "#1 merged 14 days ago by merger",
        thumbnail_url: AvatarURL.create("user@example.com"),
        fields: [
          %Field{short: true, title: "State", value: "merged"},
          %Field{short: true, title: "Assignee", value: "assignee"}],
        labels: [
          %Label{color: "#fff", value: "Label"}]}
    end
  end

  defp mock_get_by(_account, _url) do
    {:ok,
     %{body: %{
         "title" => "Title",
         "state" => "merged",
         "merged_by" => %{"login" => "merger"},
         "user" => %{"avatar_url" => AvatarURL.create("user@example.com")},
         "merged" => true,
         "number" => "1",
         "state" => "merged",
         "assignees" => [%{"login" => "assignee"}],
         "labels" => [%{"color" => "fff", "name" => "Label"}],
         "merged_at" => time
       },
       status_code: 200
     }
    }
  end

  defp time do
    DateTime.utc_now
    |> Timex.subtract(Timex.Duration.from_weeks(2))
    |> DateTime.to_iso8601
  end
end
