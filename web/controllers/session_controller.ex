defmodule CanvasAPI.SessionController do
  use CanvasAPI.Web, :controller

  def delete(conn, _params) do
    conn
    |> fetch_session
    |> clear_session
    |> send_resp(204, "")
  end
end
