defmodule CanvasAPI.CanvasWatchController do
  @moduledoc """
  A controller for responding to requests related to canvas watches
  """

  use CanvasAPI.Web, :controller

  alias CanvasAPI.CanvasWatchService

  plug CanvasAPI.CurrentAccountPlug
  plug CanvasAPI.JSONAPIPlug when action in [:create, :index]

  @doc """
  Create a new canvas watch from request params.
  """
  @spec create(Plug.Conn.t, Plug.Conn.params) :: Plug.Conn.t
  def create(conn = %{private: %{parsed_request: parsed_request}}, _) do
    parsed_request.attrs
    |> CanvasWatchService.insert(parsed_request.opts)
    |> case do
      {:ok, canvas_watch} ->
        created(conn, canvas_watch: canvas_watch)
      {:error, changeset} ->
        unprocessable_entity(conn, changeset)
    end
  end

  @doc """
  List canvas watches.
  """
  @spec index(Plug.Conn.t, Plug.Conn.params) :: Plug.Conn.t
  def index(conn = %{private: %{parsed_request: parsed_request}}, _) do
    canvas_watches =
      parsed_request.opts
      |> CanvasWatchService.list
    render(conn, "index.json", canvas_watches: canvas_watches)
  end

  @doc """
  Delete a canvas watch (the watch, not the canvas).
  """
  @spec delete(Plug.Conn.t, Plug.Conn.params) :: Plug.Conn.t
  def delete(conn, params) do
    params["id"]
    |> CanvasWatchService.delete(account: conn.private.current_account)
    |> case do
      {:ok, _} ->
        no_content(conn)
      {:error, :watch_not_found} ->
        not_found(conn, detail: "Watched canvas not found")
    end
  end
end
