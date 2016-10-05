defmodule CanvasAPI.CommonRenders do
  @moduledoc """
  Provides common renders for controllers.
  """

  alias CanvasAPI.{ChangesetView, ErrorView}

  import Phoenix.Controller
  import Plug.Conn

  def bad_request(conn, opts \\ []) do
    conn
    |> maybe_halt(opts[:halt])
    |> put_status(:bad_request)
    |> render(ErrorView, "400.json")
  end

  def not_found(conn, opts \\ []) do
    conn
    |> put_status(:not_found)
    |> maybe_halt(opts[:halt])
    |> render(ErrorView, "404.json")
  end

  def unauthorized(conn, opts \\ []) do
    conn
    |> maybe_halt(opts[:halt])
    |> put_status(:unauthorized)
    |> render(ErrorView, "401.json")
  end

  def unprocessable_entity(conn, changeset) do
    conn
    |> put_status(:unprocessable_entity)
    |> render(ChangesetView, "error.json", changeset: changeset)
  end

  defp maybe_halt(conn, true), do: halt(conn)
  defp maybe_halt(conn, _), do: conn
end
