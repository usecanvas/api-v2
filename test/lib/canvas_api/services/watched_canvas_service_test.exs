defmodule CanvasAPI.WatchedCanvasServiceTest do
  use CanvasAPI.ModelCase, async: true

  import CanvasAPI.Factory

  alias CanvasAPI.WatchedCanvasService

  setup do
    {:ok, canvas: insert(:canvas)}
  end

  describe ".insert/2" do
    test "inserts a watched canvas when found", %{canvas: canvas} do
      {:ok, watched_canvas} =
        %{"canvas_id" => canvas.id}
        |> WatchedCanvasService.insert(account: canvas.creator.account)
      assert watched_canvas.canvas_id == canvas.id
    end

    test "returns a changeset when invalid", %{canvas: canvas} do
      assert {:error, _changeset} =
        %{"canvas_id" => canvas.id}
        |> WatchedCanvasService.insert(account: insert(:account))
    end
  end
end
