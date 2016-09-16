defmodule CanvasAPI.CanvasControllerTest do
  use CanvasAPI.ConnCase

  alias CanvasAPI.Account

  @valid_attrs %{}
  @invalid_attrs %{}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists all entries on index", %{conn: conn} do
    account = Repo.insert! %Account{}

    conn =
      conn
      |> put_private(:current_account, account)
      |> get(team_path(conn, :index))

    assert json_response(conn, 200)["data"] == []
  end
end
