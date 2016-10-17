defmodule CanvasAPI.BulkAdapter do
  @moduledoc """
  A no-op adapter to ensure that `send_resp` in a bulk request does not write to
  a socket.
  """

  def read_req_body(body, _opts) do
    {:ok, Poison.encode!(body), body}
  end

  def send_resp(payload, _status, _headers, body) do
    {:ok, body, payload}
  end
end
