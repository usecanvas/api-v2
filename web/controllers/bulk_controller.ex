defmodule CanvasAPI.BulkController do
  @moduledoc """
  Takes a list of request descriptors, which is an object containing information
  about an HTTP request, processes them as if they were each individual
  requests.
  """

  use CanvasAPI.Web, :controller

  def bulk(conn, %{"data" => request_descriptors}) do
    response_descriptors =
      request_descriptors
      |> Enum.chunk(10, 10, [])
      |> Enum.map(&Task.async(__MODULE__, :handle_sub_requests, [&1, conn]))
      |> Enum.flat_map(&Task.await(&1, 20_000))

    conn
    |> render("bulk.json", descriptors: response_descriptors)
  end

  def handle_sub_requests(request_descriptors, conn) do
    request_descriptors
    |> Enum.map(&(handle_sub_request(&1, conn)))
  end

  def handle_sub_request(request_descriptor, conn) do
    request_descriptor
    |> to_conn(conn)
    |> CanvasAPI.Endpoint.call([])
    |> to_response_descriptor
  end

  defp to_conn(request_descriptor, conn) do
    uri = URI.parse(request_descriptor["path"])
    path_info = uri.path |> String.split("/", trim: true)
    body = request_descriptor["body"] || ""
    query_string = uri.query || ""

    %Plug.Conn{conn | adapter: {CanvasAPI.BulkAdapter, body},
                      body_params: %Plug.Conn.Unfetched{aspect: :body_params},
                      params: %Plug.Conn.Unfetched{aspect: :params},
                      method: request_descriptor["method"],
                      path_info: path_info,
                      private: Map.delete(conn.private, :phoenix_view),
                      query_string: query_string,
                      query_params: %Plug.Conn.Unfetched{aspect: :query_params},
                      request_path: uri.path}
  end

  defp to_response_descriptor(conn) do
    %{
      body: Poison.decode!(conn.resp_body),
      status: conn.status
    }
  end
end
