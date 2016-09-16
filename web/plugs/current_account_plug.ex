defmodule CanvasAPI.CurrentAccountPlug do
  alias CanvasAPI.{Account, Repo}
  import Phoenix.Controller
  import Plug.Conn

  def init(opts), do: opts

  def call(conn = %{private: %{current_account: %Account{}}}, _), do: conn

  def call(conn, opts) do
    with conn <- fetch_session(conn),
         account_id when not is_nil(account_id) <- get_session(conn, :account_id),
         account = %Account{} <- Repo.get(Account, account_id) do
      put_private(conn, :current_account, account)
    else
      _ ->
        if opts[:permit_none] do
          conn
        else
          conn
          |> halt
          |> put_status(:unauthorized)
          |> render(CanvasAPI.ErrorView, "401.json")
        end
    end
  end
end
