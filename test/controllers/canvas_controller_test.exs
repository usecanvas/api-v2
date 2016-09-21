defmodule CanvasAPI.CanvasControllerTest do
  use CanvasAPI.ConnCase

  alias CanvasAPI.Account

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
    end

    test "can be filtered", %{conn: conn} do
      canvas = insert(:canvas)
      account = canvas.creator.account

      params = %{"filter" => %{"is_template" => true}}

      conn =
        build_conn
        |> put_private(:current_account, account)
        |> get(team_canvas_path(conn, :index, canvas.team), params)

      assert json_response(conn, 200)["data"] == []
    end
  end
end
