defmodule CanvasAPI.Unfurl.GitHub.APITest do
  use CanvasAPI.ModelCase

  alias CanvasAPI.Unfurl.GitHub.API, as: GitHubAPI

  import CanvasAPI.Factory
  import Mock

  test ".get_by uses an account GitHub OAuth token" do
    account = insert(:account)
    token = insert(:oauth_token, account: account, provider: "github")

    with_mock HTTPoison.Base, [request: &mock_request/9] do
      GitHubAPI.get_by(account, "/repos")
      assert called HTTPoison.Base.request(
        GitHubAPI,
        :get,
        "https://api.github.com/repos",
        "",
        [{"authorization", "token #{token.token}"}],
        :_,
        :_,
        :_,
        :_)
    end
  end

  defp mock_request(_, _, _, _, _, _, _, _, _) do
    {:ok, %HTTPoison.Response{}}
  end
end
