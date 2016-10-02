defmodule CanvasAPI.TeamController do
  use CanvasAPI.Web, :controller

  alias CanvasAPI.{ErrorView, Team}

  plug CanvasAPI.CurrentAccountPlug

  def index(conn, params, current_account) do
    teams =
      from(assoc(current_account, :teams),
           order_by: [:name],
           preload: [users: ^assoc(current_account, :users)])
      |> filter(params["filter"])
      |> Repo.all

    render(conn, "index.json", teams: teams)
  end

  def show(conn, %{"id" => id}, current_account) do
    assoc(current_account, :teams)
    |> preload([users: ^assoc(current_account, :users)])
    |> Repo.get(id)
    |> case do
      team = %Team{} ->
        render(conn, "show.json", team: team)
      _ ->
        conn
        |> put_status(:not_found)
        |> render(ErrorView, "404.json")
    end
  end

  def action(conn, _) do
    apply(__MODULE__, action_name(conn), [conn,
                                          conn.params,
                                          conn.private.current_account])
  end

  defp filter(query, %{"domain" => domain}), do: where(query, [domain: ^domain])
  defp filter(query, _), do: query
end
