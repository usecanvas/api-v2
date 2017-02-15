defmodule CanvasAPI.ExportController do
  @moduledoc """
  Controller for data exports.
  """

  use CanvasAPI.Web, :controller

  alias CanvasAPI.{ErrorView, ExportService}

  plug CanvasAPI.CurrentAccountPlug when action in [:show]

  @doc """
  Get a data export token for a team.
  """
  @spec show(Plug.Conn.t, Plug.Conn.params) :: Plug.Conn.t
  def show(conn, %{"team_id" => team_id}) do
    conn.private[:current_account]
    |> ExportService.get_token(team_id)
    |> case do
      {:ok, token} ->
        conn
        |> send_resp(:ok, Poison.encode!(%{"token" => token}))
      {:error, :not_found} ->
        conn
        |> put_status(:not_found)
        |> render(ErrorView, "404.json")
    end
  end

  @doc """
  Download a data export.
  """
  @spec download(Plug.Conn.t, Plug.Conn.params) :: Plug.Conn.t
  def download(conn, %{"token" => token}) do
    token
    |> ExportService.get
    |> case do
      {:ok, {name, content}} ->
        conn
        |> put_resp_header("content-disposition",
                           "attachment; filename=#{name}")
        |> put_resp_content_type("application/octet-stream")
        |> send_resp(:ok, content)
      {:error, _} ->
        conn
        |> put_status(:not_found)
        |> render(ErrorView, "404.json")
    end
  end
end
