defmodule CanvasAPI.TeamController do
  use CanvasAPI.Web, :controller

  alias CanvasAPI.TeamService

  plug CanvasAPI.CurrentAccountPlug when not action in [:show]
  plug CanvasAPI.CurrentAccountPlug, [permit_none: true] when action in [:show]

  def index(conn, params, current_account) do
    teams =
      TeamService.list(current_account, filter: params["filter"])
      |> Enum.map(& TeamService.add_account_user(&1, current_account))
    render(conn, "index.json", teams: teams)
  end

  def show(conn, %{"id" => id}, current_account) do
    with {:ok, team} <- TeamService.show(id),
         team = TeamService.add_account_user(team, current_account) do
      render(conn, "show.json", team: team)
    else
      {:error, :not_found} ->
        not_found(conn)
    end
  end

  def action(conn, _) do
    apply(__MODULE__, action_name(conn), [conn,
                                          conn.params,
                                          conn.private[:current_account]])
  end
end
