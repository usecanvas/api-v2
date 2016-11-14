defmodule CanvasAPI.OAuth.GitHub.CallbackController do
  use CanvasAPI.Web, :controller

  alias CanvasAPI.GitHubOAuthMediator

  @redirect_on_auth_url Application.get_env(:canvas_api, :redirect_on_auth_url)

  plug CanvasAPI.CurrentAccountPlug

  @doc """
  Respond to a GitHub OAuth callback by persisting a token
  """
  @spec callback(Plug.Conn.t, Plug.Conn.params) :: Plug.Conn.t
  def callback(conn, %{"code" => code}) do
    GitHubOAuthMediator.persist_token(
      code, account: conn.private.current_account)
    |> case do
      {:ok, _} ->
        redirect(conn, external: @redirect_on_auth_url)
      {:error, _error} ->
        bad_request(conn)
    end
  end
end
