defmodule CanvasAPI.CanvasTest do
  use CanvasAPI.ModelCase

  alias CanvasAPI.Canvas

  @valid_attrs %{}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Canvas.changeset(%Canvas{}, @valid_attrs)
    assert changeset.valid?
  end
end
