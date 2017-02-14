defmodule CanvasAPI.ExportController do
  @moduledoc """
  Controller for data exports.
  """

  use CanvasAPI.Web, :controller

  alias CanvasAPI.{ErrorView, ExportService}

  plug CanvasAPI.CurrentAccountPlug

  @doc """
  Get a data export for a team.
  """
  @spec show(Plug.Conn.t, Plug.Conn.params) :: Plug.Conn.t
  def show(conn, %{"team_id" => team_id}) do
    team_id
    |> ExportService.get(account: conn.private[:current_account])
    |> case do
      {:ok, {name, content}} ->
        conn
        |> put_resp_header("content-disposition",
                           "attachment; filename=#{name}")
        |> put_resp_content_type("application/octet-stream")
        |> send_resp(:ok, content)
      {:error, :not_found} ->
        conn
        |> put_status(:not_found)
        |> render(ErrorView, "404.json")
    end
  end
end
