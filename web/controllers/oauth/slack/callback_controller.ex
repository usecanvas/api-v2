defmodule CanvasAPI.OAuth.Slack.CallbackController do
  use CanvasAPI.Web, :controller

  alias CanvasAPI.{AddToSlackMediator, ErrorView, SignInMediator}

  plug CanvasAPI.CurrentAccountPlug, permit_none: true


  @doc """
  Respond to a Slack OAuth callback by creating a new user and team.
  """
  @spec sign_in(Plug.Conn.t, Plug.Conn.params) :: Plug.Conn.t
  def sign_in(conn, %{"code" => code, "state" => "identity"}) do
    account = conn.private[:current_account]

    case SignInMediator.sign_in(code, account: account) do
      {:ok, account} ->
        conn
        |> put_resp_cookie("csrf_token", get_csrf_token(),
                           domain: System.get_env("COOKIE_DOMAIN"),
                           max_age: 604_800 * 2, # 2 weeks (expires with logout)
                           http_only: false)
        |> put_session(:account_id, account.id)
        |> redirect(external: System.get_env("REDIRECT_ON_LOGIN_URL"))
      {:error, _error} ->
        conn
        |> put_status(:bad_request)
        |> render(ErrorView, "400.json")
    end
  end

  @doc """
  Respond to an Add-to-Slack OAuth callback by creating a token for the team.
  """
  @spec add_to(Plug.Conn.t, Plug.Conn.params) :: Plug.Conn.t
  def add_to(conn, %{"code" => code, "state" => "add"}) do
    case AddToSlackMediator.add(code) do
      {:ok, token} ->
        conn
        |> redirect(external: System.get_env("REDIRECT_ON_LOGIN_URL"))
      _ ->
        conn
        |> put_status(:bad_request)
        |> render(ErrorView, "400.json")
    end
  end
end
