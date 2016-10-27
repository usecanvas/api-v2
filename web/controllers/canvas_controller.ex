defmodule CanvasAPI.CanvasController do
  use CanvasAPI.Web, :controller

  alias CanvasAPI.{Canvas, CanvasService}

  plug CanvasAPI.CurrentAccountPlug when not action in [:show]
  plug CanvasAPI.CurrentAccountPlug, [permit_none: true] when action in [:show]
  plug :ensure_team when not action in [:show]
  plug :ensure_user when not action in [:show]
  plug :ensure_canvas when action in [:update]

  def create(conn, params) do
    case CanvasService.create(
      get_in(params, ~w(data attributes)),
      creator: conn.private.current_user,
      team: conn.private.current_team,
      template: get_in(params, ~w(data relationships template data)),
      notify: conn.private.current_user) do
        {:ok, canvas} ->
          conn
          |> put_status(:created)
          |> render("show.json", canvas: canvas)
        {:error, changeset} ->
          unprocessable_entity(conn, changeset)
      end
  end

  def index(conn, _params) do
    canvases = CanvasService.list(user: conn.private.current_user)
    render(conn, "index.json", canvases: canvases)
  end

  def index_templates(conn, _params) do
    templates =
      CanvasService.list(user: conn.private.current_user, only_templates: true)
    render(conn, "index.json", canvases: templates)
  end

  def show(conn, params = %{"id" => id, "team_id" => team_id}) do
    case CanvasService.show(id,
                            account: conn.private.current_account,
                            team_id: team_id) do
      canvas = %Canvas{} ->
        render_show(conn, canvas, params["trailing_format"])
      nil ->
        not_found(conn)
    end
  end

  def update(conn, params) do
    case CanvasService.update(
      conn.private.canvas,
      get_in(params, ~w(data attributes)),
      notify: conn.private.current_user) do
        {:ok, canvas} ->
          render_show(conn, canvas)
        {:error, changeset} ->
          unprocessable_entity(conn, changeset)
      end
  end

  def delete(conn, %{"id" => id, "team_id" => team_id}) do
    case CanvasService.delete(id,
                              account: conn.private.current_account,
                              team_id: team_id) do
      {:ok, _} ->
        send_resp(conn, :no_content, "")
      {:error, changeset} ->
        unprocessable_entity(conn, changeset)
      nil ->
        not_found(conn)
    end
  end

  defp ensure_canvas(conn, _opts) do
    CanvasService.show(conn.params["id"],
                       account: conn.private.current_account,
                       team_id: conn.params["team_id"])
    |> case do
      canvas when canvas != nil -> put_private(conn, :canvas, canvas)
      nil -> not_found(conn, halt: true)
    end
  end

  defp render_show(conn, canvas, format \\ "json")

  defp render_show(conn, canvas, "canvas") do
    conn
    |> put_resp_header("content-type", "application/octet-stream")
    |> render("canvas.json", canvas: canvas, json_api: false)
  end

  defp render_show(conn, canvas, _) do
    render(conn, "show.json", canvas: canvas)
  end
end
