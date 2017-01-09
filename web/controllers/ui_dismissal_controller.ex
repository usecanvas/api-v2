defmodule CanvasAPI.UIDismissalController do
  use CanvasAPI.Web, :controller

  alias CanvasAPI.UIDismissalService

  plug CanvasAPI.CurrentAccountPlug

  @spec index(Plug.Conn.t, Plug.Conn.params) :: Plug.Conn.t
  def index(conn, _params) do
    dismissals = UIDismissalService.list(conn.private.current_account)
    render(conn, "index.json", ui_dismissals: dismissals)
  end

  @spec create(Plug.Conn.t, Plug.Conn.params) :: Plug.Conn.t
  def create(conn, params) do
    case UIDismissalService.create(
      get_in(params, ~w(data attributes)),
      account: conn.private.current_account) do
        {:ok, dismissal} ->
          conn
          |> put_status(:created)
          |> render("show.json", ui_dismissal: dismissal)
        {:error, changeset} ->
          unprocessable_entity(conn, changeset)
    end
  end
end
