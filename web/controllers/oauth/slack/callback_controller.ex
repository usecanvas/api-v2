defmodule CanvasAPI.OAuth.Slack.CallbackController do
  use CanvasAPI.Web, :controller

  alias CanvasAPI.{ErrorView, SignInMediator}

  plug CanvasAPI.CurrentAccountPlug, permit_none: true

  @doc """
  Respond to a Slack OAuth callback by creating a new user and team.
  """
  @spec callback(Plug.Conn.t, Plug.Conn.params) :: Plug.Conn.t
  def callback(conn, %{"code" => code, "state" => "identity"}) do
    account = conn.private[:current_account]

    case SignInMediator.sign_in(code, account: account) do
      {:ok, account} ->
        conn
        |> fetch_session
        |> put_session(:account_id, account.id)
        |> redirect(external: System.get_env("REDIRECT_ON_LOGIN_URL"))
      {:error, _error} ->
        conn
        |> put_status(:bad_request)
        |> render(ErrorView, "400.json")
    end
  end
end
