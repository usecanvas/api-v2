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

  describe ".index/2" do
    test "lists comments for an account" do
      comment = insert(:comment)
      comments = CommentService.list(account: comment.creator.account)
      assert List.first(comments).id == comment.id
    end

    test "lists comments filtered by canvas" do
      canvas = insert(:canvas)
      comment = insert(:comment, canvas: canvas)
      canvas_2 = insert(:canvas, team: canvas.team)
      insert(:comment, canvas: canvas_2)
      [found_comment] = CommentService.list(account: canvas.creator.account,
                                            filter: %{"canvas.id" => canvas.id})
      assert found_comment.id == comment.id
    end
  end
end
