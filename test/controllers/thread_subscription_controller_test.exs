defmodule CanvasAPI.ThreadSubscriptionControllerTest do
  use CanvasAPI.ConnCase, async: true

  import CanvasAPI.Factory

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "PUT .upsert/2" do
    test "creates when no subscription exists", %{conn: conn} do
      canvas = insert(:canvas)
      block = List.first(canvas.blocks)

      data = %{
        attributes: %{subscribed: false},
        relationships: %{
          canvas: %{data: %{id: canvas.id, type: "canvas"}}}}

      conn =
        conn
        |> put_private(:current_account, canvas.creator.account)
        |> put(thread_subscription_path(conn, :upsert, block.id,
                                         %{data: data}))

      assert json_response(conn, 200)
    end

    test "updates when a subscription exists", %{conn: conn} do
      sub = insert(:thread_subscription, subscribed: false)

      data = %{
        attributes: %{subscribed: true},
        relationships: %{
          canvas: %{data: %{id: sub.canvas.id, type: "canvas"}}}}

      conn =
        conn
        |> put_private(:current_account, sub.user.account)
        |> put(thread_subscription_path(conn, :upsert, sub.block_id,
                                         %{data: data}))

      assert json_response(conn, 200)
      assert Repo.reload(sub).subscribed
    end
  end

  describe "GET .index/2" do
    test "lists thread subscriptions", %{conn: conn} do
      sub = insert(:thread_subscription)

      conn =
        conn
        |> put_private(:current_account, sub.user.account)
        |> get(thread_subscription_path(conn, :index))

      assert conn
             |> json_response(200)
             |> Map.get("data")
             |> Enum.map(&(&1["id"])) == [sub.block_id]
    end

    test "lists only user's subscriptions", %{conn: conn} do
      sub = insert(:thread_subscription)
      insert(:thread_subscription, canvas: sub.canvas)

      conn =
        conn
        |> put_private(:current_account, sub.user.account)
        |> get(thread_subscription_path(conn, :index))

      assert conn
             |> json_response(200)
             |> Map.get("data")
             |> Enum.map(&(&1["id"])) == [sub.block_id]
    end

    test "filters by block ID", %{conn: conn} do
      sub = insert(:thread_subscription)
      insert(:thread_subscription,
             user: sub.user, block_id: "XXX", canvas: sub.canvas)

      conn =
        conn
        |> put_private(:current_account, sub.user.account)
        |> get(thread_subscription_path(conn, :index),
               %{"filter" => %{"block.id" => sub.block_id}})

      assert conn
             |> json_response(200)
             |> Map.get("data")
             |> Enum.map(&(&1["id"])) == [sub.block_id]
    end

    test "filters by canvas ID", %{conn: conn} do
      sub = insert(:thread_subscription)
      insert(:thread_subscription,
             user: sub.user,
             block_id: sub.block_id,
             canvas: insert(:canvas, creator: sub.user, team: sub.canvas.team))

      conn =
        conn
        |> put_private(:current_account, sub.user.account)
        |> get(thread_subscription_path(conn, :index),
               %{"filter" => %{"canvas.id" => sub.canvas_id}})

      assert conn
             |> json_response(200)
             |> Map.get("data")
             |> Enum.map(&(&1["id"])) == [sub.block_id]
    end
  end
end
