defmodule CanvasAPI.CanvasWatchServiceTest do
  use CanvasAPI.ModelCase, async: true

  import CanvasAPI.Factory

  alias CanvasAPI.CanvasWatchService

  describe ".insert/2" do
    setup do
      {:ok, canvas: insert(:canvas)}
    end

    test "inserts a canvas watch when found", %{canvas: canvas} do
      {:ok, canvas_watch} =
        %{"canvas_id" => canvas.id}
        |> CanvasWatchService.insert(account: canvas.creator.account)
      assert canvas_watch.canvas_id == canvas.id
    end

    test "returns a changeset when invalid", %{canvas: canvas} do
      assert {:error, _changeset} =
        %{"canvas_id" => canvas.id}
        |> CanvasWatchService.insert(account: insert(:account))
    end
  end

  describe ".list/1" do
    test "lists canvas watches" do
      watch = insert(:canvas_watch)
      list = CanvasWatchService.list(account: watch.user.account)
      assert Enum.map(list, (&(&1.id))) == [watch.id]
    end

    test "filters by canvas ID" do
      user = insert(:user)
      canvas = insert(:canvas, team: user.team)
      canvas2 = insert(:canvas, team: user.team)
      watch = insert(:canvas_watch, user: user, canvas: canvas)
      _watch2 = insert(:canvas_watch, user: user, canvas: canvas2)

      list = CanvasWatchService.list(
        account: watch.user.account,
        filter: %{"canvas.id" => watch.canvas_id})
      assert Enum.map(list, (&(&1.id))) == [watch.id]
    end
  end

  describe ".delete/2" do
    test "deletes a canvas watch" do
      watch = insert(:canvas_watch)
      {:ok, _} =
        CanvasWatchService.delete(watch.canvas_id,
                                    account: watch.user.account)
      refute Repo.reload(watch)
    end

    test "returns an error when not found" do
      assert {:error, :watch_not_found} =
        CanvasWatchService.delete(insert(:canvas_watch).id,
                                    account: insert(:account))
    end
  end
end
