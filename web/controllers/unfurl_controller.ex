defmodule CanvasAPI.UnfurlController do
  use CanvasAPI.Web, :controller

  alias CanvasAPI.Unfurl

  plug CanvasAPI.CurrentAccountPlug, permit_none: true

  def index(conn, %{"url" => url}, current_account) do
    unfurl = Unfurl.unfurl(url, account: current_account)
    render(conn, "show.json", unfurl: unfurl)
  end

  def action(conn, _) do
    apply(__MODULE__, action_name(conn), [conn,
                                          conn.params,
                                          conn.private.current_account])
  end
end
