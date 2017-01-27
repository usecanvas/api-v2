defmodule CanvasAPI.CanvasWatchTest do
  use CanvasAPI.ModelCase

  alias CanvasAPI.CanvasWatch

  @valid_attrs %{}

  test "changeset with valid attributes" do
    changeset = CanvasWatch.changeset(%CanvasWatch{}, @valid_attrs)
    assert changeset.valid?
  end
end
