defmodule CanvasAPI.CanvasController do
  use CanvasAPI.Web, :controller

  plug CanvasAPI.CurrentAccountPlug

  def index(conn, _params) do
    canvases =
      from(c in Ecto.assoc(conn.private.current_account, :canvases),
           order_by: [desc: :updated_at])
      |> Repo.all

    render(conn, "index.json", canvases: canvases)
  end
end
