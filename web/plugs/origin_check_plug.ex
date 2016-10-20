defmodule CanvasAPI.OriginCheckPlug do
  @moduledoc """
  A plug for ensuring that the origin/referer headers are valid when present.
  """

  import CanvasAPI.CommonRenders
  import Plug.Conn

  @behaviour Plug
  @do_check System.get_env("CHECK_ORIGIN") == "true"

  def init(opts), do: opts

  def call(conn, _opts) do
    if @do_check do
      IO.inspect "CHECKING ORIGIN"
      do_call(
        conn,
        [System.get_env("WEB_URL")] |> get_host,
        conn |> get_req_header("origin") |> get_host,
        conn |> get_req_header("referer") |> get_host)
    else
      IO.inspect "NOT CHECKING ORIGIN"
      conn
    end
  end

  defp do_call(conn, origin, origin, origin), do: conn
  defp do_call(conn, origin, nil, origin), do: conn
  defp do_call(conn, _, _, _) do
    bad_request(conn, halt: true)
  end

  defp get_host([header]) when header != nil,
    do: URI.parse(header) |> Map.get(:host)
  defp get_host(_), do: nil
end
