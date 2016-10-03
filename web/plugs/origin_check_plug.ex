defmodule CanvasAPI.OriginCheckPlug do
  @moduledoc """
  A plug for ensuring that the origin/referer headers are valid when present.
  """

  alias CanvasAPI.ErrorView
  import Phoenix.Controller
  import Plug.Conn

  @behaviour Plug

  def init(opts), do: opts

  def call(conn, _opts) do
    do_call(
      conn,
      [System.get_env("WEB_URL")] |> get_host,
      conn |> get_req_header("origin") |> get_host,
      conn |> get_req_header("referer") |> get_host)
  end

  defp do_call(conn, origin, origin, origin), do: conn
  defp do_call(conn, origin, nil, origin), do: conn
  defp do_call(conn, _, _, _) do
    conn
    |> halt
    |> put_status(:bad_request)
    |> render(ErrorView, "400.json")
  end

  defp get_host([header]), do: URI.parse(header) |> Map.get(:host)
  defp get_host(_), do: nil
end
