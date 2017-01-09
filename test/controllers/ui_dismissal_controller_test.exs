defmodule CanvasAPI.UIDismissalControllerTest do
  use CanvasAPI.ConnCase

  import CanvasAPI.Factory

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "GET :index" do
    test "lists UI dismissals", %{conn: conn} do
      dis = insert(:ui_dismissal)
      account = dis.account

      conn =
        conn
        |> put_private(:current_account, account)
        |> get(ui_dismissal_path(conn, :index))

      assert get_in(json_response(conn, 200), ["data", Access.at(0), "id"]) ==
        dis.id
    end
  end

  describe "POST :create" do
    test "creates a UI dismissal", %{conn: conn} do
      account = insert(:account)

      data = %{data: %{attributes: %{identifier: "ident"}}}

      conn =
        conn
        |> put_private(:current_account, account)
        |> post(ui_dismissal_path(conn, :create), data)

      assert json_response(conn, 201)
    end
  end
end
