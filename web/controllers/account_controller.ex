defmodule CanvasAPI.AccountController do
  use CanvasAPI.Web, :controller

  plug CanvasAPI.CurrentAccountPlug

  def show(conn, _params) do
    render(conn, "show.json", account: conn.private.current_account)
  end
end
