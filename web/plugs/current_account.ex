defmodule CanvasAPI.CurrentAccountPlug do
  alias CanvasAPI.{Account, Repo}
  import Phoenix.Controller
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, opts) do
    with conn <- fetch_session(conn),
         account_id <- get_session(conn, :account_id),
         account = %Account{} <- Repo.get(Account, account_id) do
      put_private(conn, :current_account, account)
    else
      _ ->
        conn
        |> put_status(:unauthorized)
        |> render(CanvasAPI.ErrorView, "unauthorized.json")
    end
  end
end
