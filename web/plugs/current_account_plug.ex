defmodule CanvasAPI.CurrentAccountPlug do
  @moduledoc """
  A plug for ensuring that the current account is present on the connection.
  """

  alias CanvasAPI.{Account, Repo}
  import CanvasAPI.CommonRenders
  import Plug.Conn

  @behaviour Plug

  def init(opts), do: opts

  def call(conn = %{private: %{current_account: %Account{}}}, _), do: conn

  def call(conn, opts) do
    with account_id when not is_nil(account_id) <-
           get_session(conn, :account_id),
         account = %Account{}
          <- Repo.get(Account, account_id) |> Repo.preload([:teams]) do
      Sentry.Context.set_user_context(%{id: account.id})
      put_private(conn, :current_account, account)
    else
      _ ->
        if opts[:permit_none] do
          put_private(conn, :current_account, nil)
        else
          unauthorized(conn, halt: true)
        end
    end
  end
end
