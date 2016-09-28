defmodule CanvasAPI.OAuth.GitHub.CallbackController do
  use CanvasAPI.Web, :controller

  alias CanvasAPI.{ErrorView, GitHubOAuthMediator}

  plug CanvasAPI.CurrentAccountPlug

  @doc """
  Respond to a GitHub OAuth callback by persisting a token
  """
  @spec callback(Plug.Conn.t, Plug.Conn.params) :: Plug.Conn.t
  def callback(conn, %{"code" => code}) do
    account = conn.private[:current_account]

    case GitHubOAuthMediator.persist_token(code, account: account) do
      {:ok, _} ->
        conn
        |> redirect(external: System.get_env("REDIRECT_ON_LOGIN_URL"))
      {:error, _error} ->
        conn
        |> put_status(:bad_request)
        |> render(ErrorView, "400.json")
    end
  end
end
