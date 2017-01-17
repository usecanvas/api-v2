defmodule CanvasAPI.CommentServiceTest do
  use CanvasAPI.ModelCase

  alias CanvasAPI.CommentService
  import CanvasAPI.Factory

  setup do
    block = build(:block, content: "Hello, world!")
    canvas = insert(:canvas, blocks: [block])
    {:ok, canvas: canvas}
  end

  describe ".create/2" do
    test "creates a new comment from valid params", %{canvas: canvas} do
      {:ok, comment} =
        %{blocks: [%{type: "paragraph", content: "Hi"}],
          canvas_id: canvas.id,
          block_id: List.first(canvas.blocks).id}
        |> CommentService.create(account: canvas.creator.account)
      assert comment
    end
  end
end
