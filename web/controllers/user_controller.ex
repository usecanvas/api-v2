defmodule CanvasAPI.UserController do
  use CanvasAPI.Web, :controller

  alias CanvasAPI.Team

  plug CanvasAPI.CurrentAccountPlug

  def show(conn, %{"team_id" => team_id}, current_account) do
    user =
      from(u in assoc(current_account, :users),
           join: t in Team, on: t.id == u.team_id,
           where: t.id == ^team_id,
           preload: [:team])
      |> Repo.one!

    render(conn, "show.json", user: user)
  end

  def action(conn, _) do
    apply(__MODULE__, action_name(conn), [conn,
                                          conn.params,
                                          conn.private.current_account])
  end
end
