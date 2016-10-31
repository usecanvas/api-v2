defmodule CanvasAPI.Unfurl.GitHub.RepoTest do
  use CanvasAPI.ModelCase

  alias CanvasAPI.{AvatarURL, Unfurl}
  alias CanvasAPI.Unfurl.GitHub.Repo, as: UnfurlRepo
  alias CanvasAPI.Unfurl.GitHub.API, as: GitHubAPI

  import CanvasAPI.Factory
  import Mock

  setup do
    account = insert(:account)
    {:ok, account: account}
  end

  test "unfurls GitHub issue URLs", %{account: account} do
    with_mock GitHubAPI, [get_by: &mock_get_by/2] do
      url = "https://github.com/usecanvas/pro-web"
      unfurl = UnfurlRepo.unfurl(url, account: account)
      assert unfurl == %Unfurl{
        id: url,
        title: "Title",
        text: "Description",
        thumbnail_url: AvatarURL.create("user@example.com")}
    end
  end

  defp mock_get_by(_account, _url) do
    {:ok,
     %{body: %{
         "full_name" => "Title",
         "description" => "Description",
         "owner" => %{"avatar_url" => AvatarURL.create("user@example.com")},
       },
       status_code: 200
     }
    }
  end
end
