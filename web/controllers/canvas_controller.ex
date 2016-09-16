defmodule CanvasAPI.CanvasController do
  use CanvasAPI.Web, :controller

  alias CanvasAPI.{ErrorView, Repo}

  plug CanvasAPI.CurrentAccountPlug
  plug :ensure_team
  plug :ensure_user

  def index(conn, _params) do
    canvases = conn.private.current_user.canvases
    render(conn, "index.json", canvases: canvases)
  end

  defp ensure_team(conn, _opts) do
    team =
      from(t in Ecto.assoc(conn.private.current_account, :teams))
      |> Repo.get(conn.params["team_id"])

    if team do
      conn
      |> put_private(:current_team, team)
    else
      conn
      |> halt
      |> put_status(:not_found)
      |> render(ErrorView, "404.json")
    end
  end

  defp ensure_user(conn, _opts) do
    user =
      from(u in Ecto.assoc(conn.private.current_account, :users),
           where: u.team_id == ^conn.private.current_team.slack_id,
           limit: 1,
           preload: [:canvases])
      |> Repo.all
      |> Enum.at(0)

    if user do
      conn
      |> put_private(:current_user, user)
    else
      conn
      |> halt
      |> put_status(:not_found)
      |> render(ErrorView, "404.json")
    end
  end
end
