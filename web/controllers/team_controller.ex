defmodule CanvasAPI.TeamController do
  use CanvasAPI.Web, :controller

  alias CanvasAPI.{ErrorView, Team}

  plug CanvasAPI.CurrentAccountPlug

  def index(conn, _params) do
    teams =
      from(t in Ecto.assoc(conn.private.current_account, :teams),
           order_by: [:name])
      |> Repo.all

    render(conn, "index.json", teams: teams)
  end

  def show(conn, %{"id" => id}) do
    team =
      Ecto.assoc(conn.private.current_account, :teams)
      |> Repo.get(id)

    case team do
      team = %Team{} ->
        conn
        |> render("show.json", team: team)
      nil ->
        conn
        |> put_status(:not_found)
        |> render(ErrorView, "404.json")
    end
  end
end
