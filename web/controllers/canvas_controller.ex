defmodule CanvasAPI.CanvasController do
  use CanvasAPI.Web, :controller

  alias CanvasAPI.{Canvas, ChangesetView, ErrorView, Repo}

  plug CanvasAPI.CurrentAccountPlug
  plug :ensure_team
  plug :ensure_user

  def create(conn, _params) do
    changeset =
      %Canvas{}
      |> Canvas.changeset
      |> Ecto.Changeset.put_assoc(:creator, conn.private.current_user)
      |> Ecto.Changeset.put_assoc(:team, conn.private.current_team)

    case Repo.insert(changeset) do
      {:ok, canvas} ->
        conn
        |> put_status(:created)
        |> render("show.json", canvas: canvas)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(ChangesetView, "error.json", changeset: changeset)
    end
  end

  def index(conn, _params) do
    canvases =
      Ecto.assoc(conn.private.current_user, :canvases)
      |> Repo.all

    render(conn, "index.json", canvases: canvases)
  end

  def show(conn, %{"id" => id}) do
    canvas =
      Ecto.assoc(conn.private.current_team, :canvases)
      |> Repo.get(id)

    case canvas do
      canvas = %Canvas{} ->
        conn
        |> render("show.json", canvas: canvas)
      nil ->
        conn
        |> put_status(:not_found)
        |> render(ErrorView, "404.json")
    end
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
           limit: 1)
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
