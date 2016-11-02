defmodule CanvasAPI.BulkAdapterTest do
  use ExUnit.Case, async: true

  alias CanvasAPI.BulkAdapter

  test ".read_req_body reads the body as a JSON string" do
    assert BulkAdapter.read_req_body(%{foo: "bar"}, []) ==
      {:ok, ~s({"foo":"bar"}), %{foo: "bar"}}
  end

  test ".send_resp just returns the body and payload" do
    assert BulkAdapter.send_resp(:payload, 200, [], :body) ==
      {:ok, :body, :payload}
  end
end
