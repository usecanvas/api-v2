defmodule CanvasAPI.UnfurlController do
  use CanvasAPI.Web, :controller

  alias CanvasAPI.Unfurl

  plug CanvasAPI.CurrentAccountPlug

  @spec index(Plug.Conn.t, Plug.Conn.params) :: Plug.Conn.t
  def index(conn, %{"url" => url}) do
    account = conn.private.current_account

    conn
    |> render("show.json", unfurl: Unfurl.unfurl(url, account: account))
  end
end
