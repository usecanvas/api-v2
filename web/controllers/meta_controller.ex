defmodule CanvasAPI.MetaController do
  use CanvasAPI.Web, :controller

  def boom(_conn, _params) do
    raise "boom"
  end

  def health(conn, _params) do
    send_resp(conn, :ok, "OK")
  end
end
