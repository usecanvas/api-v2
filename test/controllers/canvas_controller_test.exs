defmodule CanvasAPI.CanvasControllerTest do
  use CanvasAPI.ConnCase

  alias CanvasAPI.Block
  import CanvasAPI.Factory

  @valid_attrs %{}
  @invalid_attrs %{}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "GET :index" do
    test "lists all canvases", %{conn: conn} do
      canvas = insert(:canvas)
      account = canvas.creator.account

      conn =
        conn
        |> put_private(:current_account, account)
        |> get(team_canvas_path(conn, :index, canvas.team))

      %{"data" => [%{"id" => id}]} = json_response(conn, 200)
      assert id == canvas.id
    end
  end

  describe "GET :index_templates" do
    test "lists all template canvases", %{conn: conn} do
      canvas = insert(:canvas,
                      is_template: true,
                      blocks: [%Block{content: "Foo", type: "title"}])
      account = canvas.creator.account

      conn =
        conn
        |> put_private(:current_account, account)
        |> get(team_template_path(conn, :index_templates, canvas.team))

      %{"data" => [%{"id" => id}]} = json_response(conn, 200)
      assert id == canvas.id
    end
  end

  describe "GET :show" do
    test "is found when account is in team", %{conn: conn} do
      canvas = insert(:canvas, link_access: "none")
      account = canvas.creator.account |> Repo.preload([:teams])

      conn =
        conn
        |> put_private(:current_account, account)
        |> get(team_canvas_path(conn, :show, canvas.team, canvas.id))

      assert conn.status == 200
    end
  end
end
