defmodule CanvasAPI.WatchedCanvasTest do
  use CanvasAPI.ModelCase

  alias CanvasAPI.WatchedCanvas

  @valid_attrs %{}

  test "changeset with valid attributes" do
    changeset = WatchedCanvas.changeset(%WatchedCanvas{}, @valid_attrs)
    assert changeset.valid?
  end
end
