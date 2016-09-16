defmodule CanvasAPI.TeamControllerTest do
  use CanvasAPI.ConnCase

  alias CanvasAPI.Team
  @valid_attrs %{}
  @invalid_attrs %{}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, team_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "shows chosen resource", %{conn: conn} do
    team = Repo.insert! %Team{}
    conn = get conn, team_path(conn, :show, team)
    assert json_response(conn, 200)["data"] == %{"id" => team.id}
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, team_path(conn, :show, "11111111-1111-1111-1111-111111111111")
    end
  end

  test "creates and renders resource when data is valid", %{conn: conn} do
    conn = post conn, team_path(conn, :create), team: @valid_attrs
    assert json_response(conn, 201)["data"]["id"]
    assert Repo.get_by(Team, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, team_path(conn, :create), team: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates and renders chosen resource when data is valid", %{conn: conn} do
    team = Repo.insert! %Team{}
    conn = put conn, team_path(conn, :update, team), team: @valid_attrs
    assert json_response(conn, 200)["data"]["id"]
    assert Repo.get_by(Team, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    team = Repo.insert! %Team{}
    conn = put conn, team_path(conn, :update, team), team: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen resource", %{conn: conn} do
    team = Repo.insert! %Team{}
    conn = delete conn, team_path(conn, :delete, team)
    assert response(conn, 204)
    refute Repo.get(Team, team.id)
  end
end
