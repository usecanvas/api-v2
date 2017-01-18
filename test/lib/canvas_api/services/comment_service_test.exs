defmodule CanvasAPI.CommentServiceTest do
  use CanvasAPI.ModelCase

  alias CanvasAPI.CommentService
  import CanvasAPI.Factory

  setup do
    block = build(:block, content: "Hello, world!")
    list_item = build(:block, content: "List item")
    list = build(:block, type: "list", blocks: [list_item])
    canvas = insert(:canvas, blocks: [block, list])
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

    test "creates a new comment on a nested block", %{canvas: canvas} do
      list_item =
        canvas.blocks
        |> get_in([Access.at(1), Access.key(:blocks), Access.at(0)])

      {:ok, comment} =
        %{blocks: [%{type: "paragraph", content: "Hi"}],
          canvas_id: canvas.id,
          block_id: list_item.id}
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

  describe ".update/3" do
    test "updates a comment from valid params", %{canvas: canvas} do
      comment = insert(:comment, canvas: canvas, creator: canvas.creator)
      blocks = [%{type: "paragraph", content: "New"}]
      {:ok, comment} = CommentService.update(
        comment.id, %{blocks: blocks}, account: canvas.creator.account)
      assert Repo.reload(comment).blocks |> Enum.map(&(&1.content)) == ["New"]
    end
  end
end
