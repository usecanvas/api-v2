defmodule CanvasAPI.Slack.ChannelControllerTest do
  use CanvasAPI.ConnCase

  alias CanvasAPI.Slack.Channel
  @valid_attrs %{}
  @invalid_attrs %{}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, channel_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "shows chosen resource", %{conn: conn} do
    channel = Repo.insert! %Channel{}
    conn = get conn, channel_path(conn, :show, channel)
    assert json_response(conn, 200)["data"] == %{"id" => channel.id}
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, channel_path(conn, :show, "11111111-1111-1111-1111-111111111111")
    end
  end

  test "creates and renders resource when data is valid", %{conn: conn} do
    conn = post conn, channel_path(conn, :create), channel: @valid_attrs
    assert json_response(conn, 201)["data"]["id"]
    assert Repo.get_by(Channel, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, channel_path(conn, :create), channel: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates and renders chosen resource when data is valid", %{conn: conn} do
    channel = Repo.insert! %Channel{}
    conn = put conn, channel_path(conn, :update, channel), channel: @valid_attrs
    assert json_response(conn, 200)["data"]["id"]
    assert Repo.get_by(Channel, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    channel = Repo.insert! %Channel{}
    conn = put conn, channel_path(conn, :update, channel), channel: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen resource", %{conn: conn} do
    channel = Repo.insert! %Channel{}
    conn = delete conn, channel_path(conn, :delete, channel)
    assert response(conn, 204)
    refute Repo.get(Channel, channel.id)
  end
end
