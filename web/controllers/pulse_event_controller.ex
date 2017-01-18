defmodule CanvasAPI.PulseEventController do
  use CanvasAPI.Web, :controller

  alias CanvasAPI.CanvasService

  plug CanvasAPI.CurrentAccountPlug
  plug :ensure_team
  plug :ensure_user
  plug :ensure_canvas

  def index(conn, _params) do
    pulse_events =
      from(assoc(conn.private.canvas, :pulse_events),
           order_by: [desc: :inserted_at],
           preload: [:canvas])
      |> Repo.all
    render(conn, "index.json", pulse_events: pulse_events)
  end

  defp ensure_canvas(conn, _opts) do
    CanvasService.get(conn.params["canvas_id"],
                      account: conn.private.current_account)
    |> case do
      {:ok, canvas} -> put_private(conn, :canvas, canvas)
      {:error, :not_found} -> not_found(conn, halt: true)
    end
  end
end
