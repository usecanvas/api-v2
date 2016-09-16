defmodule CanvasAPI.TeamController do
  use CanvasAPI.Web, :controller

  plug CanvasAPI.CurrentAccountPlug

  def index(conn, _params) do
    teams =
      from(t in Ecto.assoc(conn.private.current_account, :teams),
           order_by: [:name])
      |> Repo.all

    render(conn, "index.json", teams: teams)
  end
end
