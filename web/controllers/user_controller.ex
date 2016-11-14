defmodule CanvasAPI.UserController do
  use CanvasAPI.Web, :controller

  alias CanvasAPI.UserService

  plug CanvasAPI.CurrentAccountPlug

  @spec show(Plug.Conn.t, Plug.Conn.params) :: Plug.Conn.t
  def show(conn, %{"team_id" => team_id}) do
    UserService.find_by_team(conn.private.current_account, team_id: team_id)
    |> case do
      {:ok, user} ->
        render(conn, "show.json", user: user)
      {:error, :not_found} ->
        not_found(conn)
    end
  end
end
