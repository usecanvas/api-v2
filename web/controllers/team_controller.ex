defmodule CanvasAPI.TeamController do
  use CanvasAPI.Web, :controller

  alias CanvasAPI.{ErrorView, Team}

  import Ecto, only: [assoc: 2]

  plug CanvasAPI.CurrentAccountPlug

  def index(conn, params) do
    account = conn.private.current_account

    teams =
      from(t in assoc(account, :teams),
           order_by: [:name],
           preload: [users: ^from(u in assoc(account, :users))])
      |> filter(params["filter"])
      |> Repo.all

    render(conn, "index.json", teams: teams)
  end

  def show(conn, %{"id" => id}) do
    account = conn.private.current_account

    team =
      Ecto.assoc(conn.private.current_account, :teams)
      |> preload([users: ^from(u in assoc(account, :users))])
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

  defp filter(query, %{"domain" => domain}) do
    query
    |> where([t], t.domain == ^domain)
  end

  defp filter(query, _), do: query
end
