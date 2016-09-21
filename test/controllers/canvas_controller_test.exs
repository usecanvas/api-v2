defmodule CanvasAPI.CanvasControllerTest do
  use CanvasAPI.ConnCase

  import CanvasAPI.Factory

  @valid_attrs %{}
  @invalid_attrs %{}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "GET :index" do
    test "lists all entries on index", %{conn: conn} do
      canvas = insert(:canvas)
      account = canvas.creator.account

      conn =
        conn
        |> put_private(:current_account, account)
        |> get(team_canvas_path(conn, :index, canvas.team))

      %{"data" => [%{"id" => id}]} = json_response(conn, 200)
      assert id == canvas.id
      canvas = insert(:canvas)
      account = canvas.creator.account

      conn =
        build_conn
        |> put_private(:current_account, account)
        |> get(team_canvas_path(conn, :index, canvas.team))

      %{"data" => [%{"id" => id}]} = json_response(conn, 200)
      assert id == canvas.id
    end
  end
end
