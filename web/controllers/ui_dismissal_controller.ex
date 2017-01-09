defmodule CanvasAPI.UIDismissalController do
  use CanvasAPI.Web, :controller

  alias CanvasAPI.UIDismissalService

  plug CanvasAPI.CurrentAccountPlug

  @spec index(Plug.Conn.t, Plug.Conn.params) :: Plug.Conn.t
  def index(conn, _params) do
    dismissals = UIDismissalService.list(conn.private.current_account)
    render(conn, "index.json", dismissals: dismissals)
  end
end
