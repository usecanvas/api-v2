defmodule CanvasAPI.UserControllerTest do
  use CanvasAPI.ConnCase

  alias CanvasAPI.{Account, User}
  import CanvasAPI.Factory

  @valid_attrs %{}
  @invalid_attrs %{}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  @tag :focus
  test "shows chosen resource", %{conn: conn} do
    user = insert(:user)

    conn =
      conn
      |> put_private(:current_account, user.account)
      |> get(team_user_path(conn, :show, user.team))

    assert json_response(conn, 200)["data"]["id"] == user.id
  end
end
