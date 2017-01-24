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
      assert json_response(conn, 201)["data"]["id"] == canvas.id
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

  describe "GET .index/2" do
    test "lists watched canvases", %{conn: conn} do
      watch = insert(:watched_canvas)

      conn =
        conn
        |> put_private(:current_account, watch.user.account)
        |> get(watched_canvas_path(conn, :index))

      assert(
        conn
        |> json_response(200)
        |> Map.get("data")
        |> Enum.map(&(&1["id"])) == [watch.canvas_id])
    end
  end

  describe "DELETE .delete/2" do
    test "deletes a watched canvas if found", %{conn: conn} do
      watched = insert(:watched_canvas)

      conn =
        conn
        |> put_private(:current_account, watched.user.account)
        |> delete(watched_canvas_path(conn, :delete, watched.canvas_id))

      assert response(conn, 204) == ""
      refute Repo.reload(watched)
    end

    test "returns 404 when not found", %{conn: conn} do
      watched = insert(:watched_canvas)

      conn =
        conn
        |> put_private(:current_account, watched.user.account)
        |> delete(watched_canvas_path(conn, :delete, watched.canvas_id <> "x"))

      assert Repo.reload(watched)
      assert json_response(conn, 404)
    end
  end
end
