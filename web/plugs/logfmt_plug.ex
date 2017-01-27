defmodule CanvasAPI.LogfmtPlug do
  @moduledoc """
  A plug for logging requests in the logfmt style.
  """

  require Logger
  alias Plug.Conn
  import Plug.Conn
  @behaviour Plug

  def init(opts) do
    Keyword.get(opts, :log, :info)
  end

  def call(conn, level) do
    start_time = System.monotonic_time()

    Conn.register_before_send(conn, fn conn ->
      Logger.log level, fn ->
        end_time = System.monotonic_time()
        duration = System.convert_time_unit(
          end_time - start_time, :native, :micro_seconds)

        []
        |> Keyword.put(:query, conn.query_string)
        |> Keyword.put(:duration, formatted_duration(duration))
        |> Keyword.put(:type, conn_type(conn))
        |> Keyword.put(:status, conn.status)
        |> Keyword.put(:content_type, header(conn, "content-type"))
        |> Keyword.put(:accept, header(conn, "accept"))
        |> Keyword.merge(phoenix_info(conn))
        |> Keyword.put(:path, conn.request_path)
        |> Keyword.put(:method, conn.method)
        |> Logfmt.encode
      end

      conn
    end)
  end

  defp conn_type(%{state: :chunked}), do: "chunked"
  defp conn_type(_), do: "sent"

  defp formatted_duration(dur), do: "#{Float.round(dur / 1000, 3)}ms"

  defp header(conn, header) do
    conn
    |> get_req_header(header)
    |> Enum.at(0)
  end

  defp phoenix_info(%{private: private}) do
    []
    |> Keyword.put(:controller, private[:phoenix_controller] |> Atom.to_string)
  end
end
