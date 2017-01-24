defmodule CanvasAPI.WatchedCanvasController do
  @moduledoc """
  A controller for responding to requests related to watched canvasess
  """

  use CanvasAPI.Web, :controller

  alias CanvasAPI.WatchedCanvasService

  plug CanvasAPI.CurrentAccountPlug
  plug CanvasAPI.JSONAPIPlug when action in [:create, :index]

  @doc """
  Create a new watched canvas from request params.
  """
  @spec create(Plug.Conn.t, Plug.Conn.params) :: Plug.Conn.t
  def create(conn = %{private: %{parsed_request: parsed_request}}, _) do
    parsed_request.attrs
    |> WatchedCanvasService.insert(parsed_request.opts)
    |> case do
      {:ok, watched_canvas} ->
        created(conn, watched_canvas: watched_canvas)
      {:error, changeset} ->
        unprocessable_entity(conn, changeset)
    end
  end

  @doc """
  List watched canvases.
  """
  @spec index(Plug.Conn.t, Plug.Conn.params) :: Plug.Conn.t
  def index(conn = %{private: %{parsed_request: parsed_request}}, _) do
    watched_canvases =
      parsed_request.opts
      |> WatchedCanvasService.list
    render(conn, "index.json", watched_canvases: watched_canvases)
  end

  @doc """
  Delete a watched canvas (the watch, not the canvas).
  """
  @spec delete(Plug.Conn.t, Plug.Conn.params) :: Plug.Conn.t
  def delete(conn, params) do
    params["id"]
    |> WatchedCanvasService.delete(account: conn.private.current_account)
    |> case do
      {:ok, _} ->
        no_content(conn)
      {:error, :watch_not_found} ->
        not_found(conn, detail: "Watched canvas not found")
    end
  end
end
