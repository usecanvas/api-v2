defmodule CanvasAPI.CurrentAccountPlug do
  @moduledoc """
  A plug for ensuring that the current account is present on the connection.
  """

  alias CanvasAPI.{Account, Repo, TokenService}
  import CanvasAPI.CommonRenders
  import Plug.Conn

  @behaviour Plug

  def init(opts), do: opts

  def call(conn = %{private: %{current_account: %Account{}}}, _), do: conn

  def call(conn, opts) do
    with {:ok, account} <- get_account(conn),
         account = Repo.preload(account, [:teams]) do
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

  defp get_account(conn) do
    with ["Bearer " <> token] <- get_req_header(conn, "authorization") do
      TokenService.verify(token)
    else
      _ -> get_account_from_session(conn)
    end
  end

  defp get_account_from_session(conn) do
    with account_id when not is_nil(account_id)
           <- get_session(conn, :account_id),
         account when not is_nil(account) <- Repo.get(Account, account_id) do
      {:ok, account}
    else
      err = {:error, _} -> err
      err -> {:error, err}
    end
  end
end
