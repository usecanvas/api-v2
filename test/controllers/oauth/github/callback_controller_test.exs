defmodule CanvasAPI.OAuth.GitHub.CallbackControllerTest do
  use CanvasAPI.ConnCase

  alias CanvasAPI.GitHubOAuthMediator, as: GHOMediator

  import CanvasAPI.Factory
  import Mock

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json"),
          acct: insert(:account)}
  end

  describe "GET .callback/2" do
    test "redirects to auth URL when successful", %{conn: conn, acct: acct} do
      with_mock GHOMediator, [persist_token: &pass_persist_token/2] do
        conn =
          conn
          |> put_private(:current_account, acct)
          |> get(github_callback_path(conn, :callback), code: "code")
        assert response(conn, 302)
        assert get_resp_header(conn, "location") ==
          ["http://localhost.test/redirect_on_auth_url"]
      end
    end

    test "returns 400 when unsuccessful", %{conn: conn, acct: acct} do
      with_mock GHOMediator, [persist_token: &fail_persist_token/2] do
        conn =
          conn
          |> put_private(:current_account, acct)
          |> get(github_callback_path(conn, :callback), code: "code")
        assert json_response(conn, 400)
      end
    end
  end

  defp pass_persist_token("code", account: _account) do
    {:ok, %CanvasAPI.OAuthToken{}}
  end

  defp fail_persist_token("code", account: _account) do
    {:error, :failed}
  end
end
