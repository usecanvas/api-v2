defmodule CanvasAPI.OpController do
  use CanvasAPI.Web, :controller

  alias CanvasAPI.CanvasService

  plug CanvasAPI.CurrentAccountPlug
  plug :ensure_team
  plug :ensure_user
  plug :ensure_canvas

  def index(conn, _params) do
    ops =
      from(assoc(conn.private.canvas, :ops),
        order_by: [asc: :version],
        preload: [:canvas])
    |> Repo.all
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
