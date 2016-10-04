defmodule CanvasAPI.TeamPlug do
  @moduledoc """
  Provides plugs that ensure that a team and user are present for a given
  request.
  """

  alias CanvasAPI.{Repo, Team, User}

  import Ecto, only: [assoc: 2]
  import Ecto.Query
  import Phoenix.Controller
  import Plug.Conn

  def ensure_team(conn, _opts) do
    from(assoc(conn.private.current_account, :teams))
    |> Repo.get(conn.params["team_id"])
    |> case do
      team = %Team{} ->
        put_private(conn, :current_team, team)
      _ ->
        conn
        |> halt
        |> put_status(:not_found)
        |> render(ErrorView, "404.json")
    end
  end

  def ensure_user(conn, _opts) do
    from(assoc(conn.private.current_account, :users),
         where: [team_id: ^conn.private.current_team.id])
    |> first
    |> Repo.one
    |> case do
      user = %User{} ->
        put_private(conn, :current_user, user)
      _ ->
        conn
        |> halt
        |> put_status(:not_found)
        |> render(ErrorView, "404.json")
    end
  end
end
