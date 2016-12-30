defmodule CanvasAPI.OpServiceTest do
  use CanvasAPI.ModelCase

  alias CanvasAPI.OpService
  import CanvasAPI.Factory

  setup do
    {:ok, canvas: insert(:canvas)}
  end

  describe ".list/1" do
    test "lists ops for the given canvas", %{canvas: canvas} do
      op = insert(:op, canvas: canvas)
      assert OpService.list(canvas: canvas) |> Enum.map(&(&1.version)) ==
        [op.version]
    end
  end
end
