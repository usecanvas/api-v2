defmodule CanvasAPI.TokenControllerTest do
  use CanvasAPI.ConnCase

  import CanvasAPI.Factory

  setup %{conn: conn} do
    account = insert(:account)
    {:ok, account: account,
          conn: put_req_header(conn, "accept", "application/json")}
  end

  describe ".create/2" do
    test "creates a token from valid attrs", %{account: account, conn: conn} do
      conn =
        conn
        |> put_private(:current_account, account)
        |> post(token_path(conn, :create), %{data: %{attributes: %{}}})

      assert json_response(conn, 201) |> get_in(~w(data attributes token))
    end
  end
end
