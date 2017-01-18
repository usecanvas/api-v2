defmodule CanvasAPI.CommentTest do
  use CanvasAPI.ModelCase

  alias CanvasAPI.Comment

  @valid_attrs %{blocks: []}

  test "changeset with valid attributes" do
    changeset = Comment.changeset(%Comment{}, @valid_attrs)
    assert changeset.valid?
  end
end
