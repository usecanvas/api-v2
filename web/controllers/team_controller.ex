defmodule CanvasAPI.TeamController do
  use CanvasAPI.Web, :controller

  alias CanvasAPI.Team

  plug CanvasAPI.CurrentAccountPlug

  def index(conn, _params) do
    teams =
      conn.private.current_account
      |> Ecto.assoc(:teams)
      |> Repo.all

    render(conn, "index.json", teams: teams)
  end
end
