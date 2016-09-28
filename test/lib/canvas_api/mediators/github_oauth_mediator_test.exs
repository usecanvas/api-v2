defmodule CanvasAPI.GitHubOAuthMediatorTest do
  use CanvasAPI.ModelCase

  alias CanvasAPI.Unfurl.GitHub.API, as: GitHubAPI
  alias CanvasAPI.GitHubOAuthMediator, as: GOM

  import Mock
  import CanvasAPI.Factory

  @mock_token "ABCDEFGHIJKLMNOP"
  @mock_body %{"access_token" => @mock_token}

  test "persists the token" do
    account = insert(:account)

    with_mock GitHubAPI, [post: mock_post] do
      {:ok, token} = GOM.persist_token("code", account: account)
      assert token.token == @mock_token
    end
  end

  test "sends properly formatted request" do
    account = insert(:account)

    with_mock GitHubAPI, [post: mock_post] do
      {:ok, _} = GOM.persist_token("code", account: account)

      assert called GitHubAPI.post(
        "https://github.com/login/oauth/access_token",
        "",
        [{"accept", "application/json"}],
        params: [{"client_id", nil},
                 {"client_secret", nil},
                 {"code", "code"}]
      )
    end
  end

  defp mock_post do
    fn (_url, _body, _headers, _options) ->
      {:ok, %HTTPoison.Response{status_code: 200, body: @mock_body}}
    end
  end
end
