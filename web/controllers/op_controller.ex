defmodule CanvasAPI.OpController do
  use CanvasAPI.Web, :controller

  alias CanvasAPI.{CanvasService, OpService}

  plug CanvasAPI.CurrentAccountPlug
  plug :ensure_team
  plug :ensure_user
  plug :ensure_canvas

  def index(conn, _params) do
    ops = OpService.list(canvas: conn.private.canvas)
    render(conn, "index.json", ops: ops)
  end

  defp ensure_canvas(conn, _opts) do
    CanvasService.get(conn.params["canvas_id"],
                      account: conn.private.current_account,
                      team_id: conn.params["team_id"])
    |> case do
      {:ok, canvas} -> put_private(conn, :canvas, canvas)
      {:error, :not_found} -> not_found(conn, halt: true)
    end
  end
end
