defmodule CanvasAPI.TrailingFormatPlug do
  @moduledoc """
  A plug that adds a "trailing_format" param to a connection if a user supplies
  one, such as ".json".
  """

  @behaviour Plug

  def init(opts), do: opts

  def call(conn, opts) do
    id_param = opts[:param] || "id"

    conn.path_info
    |> List.last
    |> String.split(".")
    |> Enum.reverse
    |> case do
      [_] ->
        conn
      [format | fragments] ->
        new_path = fragments |> Enum.reverse |> Enum.join(".")
        path_fragments = List.replace_at(conn.path_info, -1,new_path)

        params =
          conn
          |> Plug.Conn.fetch_query_params
          |> Map.get(:params)
          |> Map.put("trailing_format", format)
          |> Map.put(id_param, new_path)

        %{conn |
          path_info: path_fragments, query_params: params, params: params}
    end
  end
end
