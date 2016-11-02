defmodule CanvasAPI.TeamController do
  use CanvasAPI.Web, :controller

  alias CanvasAPI.TeamService

  plug CanvasAPI.CurrentAccountPlug when not action in [:show]
  plug CanvasAPI.CurrentAccountPlug, [permit_none: true] when action in [:show]

  def index(conn, params) do
    current_account = conn.private.current_account

    teams =
      TeamService.list(current_account, filter: params["filter"])
      |> Enum.map(& TeamService.add_account_user(&1, current_account))
    render(conn, "index.json", teams: teams)
  end

  def show(conn, %{"id" => id}) do
    current_account = conn.private[:current_account]

    with {:ok, team} <- TeamService.show(id),
         team = TeamService.add_account_user(team, current_account) do
      render(conn, "show.json", team: team)
    else
      {:error, :not_found} ->
        not_found(conn)
    end
  end

  def update(conn, params = %{"id" => id, "data" => data}) do
    current_account = conn.private.current_account

    with {:ok, team} <- TeamService.show(id, account: current_account),
         {:ok, team} <- TeamService.update(team, data["attributes"]),
         team = TeamService.add_account_user(team, current_account) do
      render(conn, "show.json", team: team)
    else
      {:error, changeset = %Ecto.Changeset{}} ->
        unprocessable_entity(conn, changeset)
      {:error, :not_found} ->
        not_found(conn)
    end
  end
end
