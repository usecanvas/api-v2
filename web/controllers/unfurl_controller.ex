defmodule CanvasAPI.UnfurlController do
  use CanvasAPI.Web, :controller

  alias CanvasAPI.{Canvas, ErrorView, Unfurl}

  plug CanvasAPI.CurrentAccountPlug
  plug :ensure_canvas

  @spec show(Plug.Conn.t, Plug.Conn.params) :: Plug.Conn.t
  def show(conn, %{"id" => id}) do
    %{current_account: account, canvas: canvas} = conn.private

    with block when not is_nil(block) <- Canvas.find_block(canvas, id),
         block = Map.put(block, :canvas, canvas) do
      conn
      |> render("show.json", unfurl: Unfurl.unfurl(block, account: account))
    else
      _ ->
        not_found(conn)
    end
  end

  defp ensure_canvas(conn = %Plug.Conn{params: %{"canvas_id" => id}}, _opts) do
    Canvas
    |> Repo.get(id)
    |> case do
      nil ->
        not_found(conn)
      canvas ->
        put_private(conn, :canvas, canvas)
    end
  end

  defp not_found(conn) do
    conn
    |> halt
    |> put_status(:not_found)
    |> render(ErrorView, "404.json")
  end
end
