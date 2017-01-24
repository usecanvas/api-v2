defmodule CanvasAPI.WatchedCanvasControllerTest do
  use CanvasAPI.ConnCase, async: true

  import CanvasAPI.Factory

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "POST .create/2" do
    test "creates a watched canvas if found", %{conn: conn} do
      canvas = insert(:canvas)
      user = insert(:user, team: canvas.team)

      data = %{
        attributes: %{},
        relationships: %{
          canvas: %{data: %{id: canvas.id, type: "canvas"}}}}

      conn =
        conn
        |> put_private(:current_account, user.account)
        |> post(watched_canvas_path(conn, :create, %{data: data}))

      assert json_response(conn, 201)["data"]["type"] == "watched-canvas"
    end

    test "returns an error when invalid", %{conn: conn} do
      canvas = insert(:canvas)

      data = %{
        attributes: %{},
        relationships: %{
          canvas: %{data: %{id: canvas.id, type: "canvas"}}}}

      conn =
        conn
        |> put_private(:current_account, insert(:account))
        |> post(watched_canvas_path(conn, :create, %{data: data}))

      assert json_response(conn, 422)
    end
  end
end
