defmodule CanvasAPI.WatchedCanvasController do
  @moduledoc """
  A controller for responding to requests related to watched canvasess
  """

  use CanvasAPI.Web, :controller

  alias CanvasAPI.WatchedCanvasService

  plug CanvasAPI.JSONAPIPlug

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
end
