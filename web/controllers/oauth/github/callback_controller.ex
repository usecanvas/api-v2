defmodule CanvasAPI.OAuth.GitHub.CallbackController do
  use CanvasAPI.Web, :controller

  alias CanvasAPI.{ErrorView, GitHubOAuthMediator}

  plug CanvasAPI.CurrentAccountPlug

  @doc """
  Respond to a GitHub OAuth callback by persisting a token
  """
  def callback(conn, %{"code" => code}, current_account) do
    case GitHubOAuthMediator.persist_token(code, account: current_account) do
      {:ok, _} ->
        redirect(conn, external: System.get_env("REDIRECT_ON_AUTH_URL"))
      {:error, _error} ->
        conn
        |> put_status(:bad_request)
        |> render(ErrorView, "400.json")
    end
  end

  def action(conn, _) do
    apply(__MODULE__, action_name(conn), [conn,
                                          conn.params,
                                          conn.private.current_account])
  end
end
