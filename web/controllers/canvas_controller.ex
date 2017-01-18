defmodule CanvasAPI.CanvasController do
  use CanvasAPI.Web, :controller

  alias CanvasAPI.CanvasService

  plug CanvasAPI.CurrentAccountPlug when not action in [:show]
  plug CanvasAPI.CurrentAccountPlug, [permit_none: true] when action in [:show]
  plug :ensure_team when not action in [:show]
  plug :ensure_user when not action in [:show]
  plug :ensure_canvas when action in [:update]

  @md_extensions ~w(markdown md mdown text txt)

  @spec create(Plug.Conn.t, Plug.Conn.params) :: Plug.Conn.t
  def create(conn, params) do
    %{current_user: current_user, current_team: current_team} = conn.private

    case CanvasService.create(
      get_in(params, ~w(data attributes)),
      creator: current_user,
      team: current_team,
      template: get_in(params, ~w(data relationships template data)),
      notify: current_team.slack_id && current_user) do
        {:ok, canvas} ->
          conn
          |> put_status(:created)
          |> render("show.json", canvas: canvas)
        {:error, changeset} ->
          unprocessable_entity(conn, changeset)
      end
  end

  @spec index(Plug.Conn.t, Plug.Conn.params) :: Plug.Conn.t
  def index(conn, _params) do
    canvases = CanvasService.list(user: conn.private.current_user)
    render(conn, "index.json", canvases: canvases)
  end

  @spec index_templates(Plug.Conn.t, Plug.Conn.params) :: Plug.Conn.t
  def index_templates(conn, _params) do
    templates =
      CanvasService.list(user: conn.private.current_user, only_templates: true)
    render(conn, "index.json", canvases: templates)
  end

  @spec show(Plug.Conn.t, Plug.Conn.params) :: Plug.Conn.t
  def show(conn, params = %{"id" => id, "team_id" => team_id}) do
    case CanvasService.show(id,
                            account: conn.private.current_account,
                            team_id: team_id) do
      {:ok, canvas} ->
        render_show(conn, canvas, params["trailing_format"])
      {:error, :not_found} ->
        not_found(conn)
    end
  end

  @spec update(Plug.Conn.t, Plug.Conn.params) :: Plug.Conn.t
  def update(conn, params) do
    %{current_user: current_user, current_team: current_team} = conn.private

    case CanvasService.update(
      conn.private.canvas,
      get_in(params, ~w(data attributes)),
      template: get_in(params, ~w(data relationships template data)),
      notify: current_team.slack_id && current_user) do
        {:ok, canvas} ->
          render_show(conn, canvas)
        {:error, changeset} ->
          unprocessable_entity(conn, changeset)
      end
  end

  @spec delete(Plug.Conn.t, Plug.Conn.params) :: Plug.Conn.t
  def delete(conn, %{"id" => id, "team_id" => team_id}) do
    account = conn.private.current_account
    case CanvasService.delete(id, account: account) do
      {:ok, _} ->
        no_content(conn)
      {:error, changeset} ->
        unprocessable_entity(conn, changeset)
      nil ->
        not_found(conn)
    end
  end

  @spec ensure_canvas(Plug.Conn.t, map) :: Plug.Conn.t
  defp ensure_canvas(conn, _opts) do
    CanvasService.get(conn.params["id"],
                      account: conn.private.current_account)
    |> case do
      {:ok, canvas} -> put_private(conn, :canvas, canvas)
      {:error, :not_found} -> not_found(conn, halt: true)
    end
  end

  @spec render_show(Plug.Conn.t, CanvasAPI.Canvas.t, String.t) :: Plug.Conn.t
  defp render_show(conn, canvas, format \\ "json")

  defp render_show(conn, canvas, "canvas") do
    conn
    |> put_resp_content_type("application/octet-stream")
    |> render("canvas.json", canvas: canvas, json_api: false)
  end

  defp render_show(conn, canvas, format) when format in @md_extensions do
    conn
    |> put_resp_content_type("text/plain")
    |> render("canvas.md", canvas: canvas)
  end

  defp render_show(conn, canvas, _) do
    render(conn, "show.json", canvas: canvas)
  end
end
