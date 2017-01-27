defmodule CanvasAPI.OAuth.Slack.CallbackController do
  use CanvasAPI.Web, :controller

  require Logger
  alias CanvasAPI.{AddToSlackMediator, BetaNotifier, SignInMediator}

  plug CanvasAPI.CurrentAccountPlug, permit_none: true

  @beta_redirect_uri System.get_env("BETA_REDIRECT_URI")

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
        |> send_resp_or_redirect()
      {:error, {:domain_not_whitelisted, domain}} ->
        BetaNotifier.delay({:notify, [domain]})
        redirect(conn, external: @beta_redirect_uri)
      {:error, error} ->
        Logger.error("Failed Slack sign in callback: #{inspect error}")
        bad_request(conn)
    end
  end

  @doc """
  Respond to an Add-to-Slack OAuth callback by creating a token for the team.
  """
  @spec add_to(Plug.Conn.t, Plug.Conn.params) :: Plug.Conn.t
  def add_to(conn, %{"code" => code, "state" => "add"}) do
    case AddToSlackMediator.add(code) do
      {:ok, _token} ->
        conn
        |> send_resp_or_redirect()
      error ->
        Logger.error("Failed Slack sign in callback: #{inspect error}")
        bad_request(conn)
    end
  end

  @spec send_resp_or_redirect(Plug.Conn.t) :: Plug.Conn.t
  defp send_resp_or_redirect(conn) do
    [user_agent | _] = get_req_header(conn, "user-agent")

    if String.contains?(user_agent, "Electron") do
      send_resp(conn, :ok, "")
    else
      redirect(conn, external: System.get_env("REDIRECT_ON_LOGIN_URL"))
    end
  end
end
