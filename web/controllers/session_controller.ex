defmodule CanvasAPI.SessionController do
  use CanvasAPI.Web, :controller

  def delete(conn, _params) do
    conn
    |> clear_session
    |> delete_resp_cookie("csrf_token")
    |> send_resp(204, "")
  end
end
