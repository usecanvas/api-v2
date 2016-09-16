defmodule CanvasAPI.AccountControllerTest do
  use CanvasAPI.ConnCase

  alias CanvasAPI.Account

  @valid_attrs %{}
  @invalid_attrs %{}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "shows chosen resource", %{conn: conn} do
    account = Repo.insert! %Account{}

    conn =
      conn
      |> put_private(:current_account, account)
      |> get(account_path(conn, :show))

    assert json_response(conn, 200)["data"]["id"] == account.id
  end
end
