defmodule CanvasAPI.UnfurlController do
  use CanvasAPI.Web, :controller

  @spec show(Plug.Conn.t, Plug.Conn.params) :: Plug.Conn.t
  def show(conn, %{"url" => url}) do
    conn
    |> render("show.json", unfurl: CanvasAPI.Unfurl.unfurl(url))
  end
end
