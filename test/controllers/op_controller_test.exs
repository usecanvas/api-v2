defmodule CanvasAPI.OpControllerTest do
  use CanvasAPI.ConnCase

  import CanvasAPI.Factory

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "GET :index" do
    test "lists ops for the canvas", %{conn: conn} do
      op = insert(:op)
      canvas = op.canvas
      account = canvas.creator.account

      conn =
        conn
        |> put_private(:current_account, account)
        |> get(team_canvas_op_path(conn, :index, canvas.team, canvas))

      assert json_response(conn, 200)
             |> get_in(["data", Access.at(0), "attributes", "version"]) ==
               op.version
    end
  end
end
