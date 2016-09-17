defmodule CanvasAPI.UserController do
  use CanvasAPI.Web, :controller

  alias CanvasAPI.Team

  plug CanvasAPI.CurrentAccountPlug

  def show(conn, %{"team_id" => team_id}) do
    user =
      from(u in Ecto.assoc(conn.private.current_account, :users),
           join: t in Team, on: t.id == u.team_id,
           where: t.id == ^team_id,
           preload: [:team])
      |> Repo.one!

    render(conn, "show.json", user: user)
  end
end
