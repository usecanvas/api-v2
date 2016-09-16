defmodule CanvasAPI.TeamTest do
  use CanvasAPI.ModelCase

  alias CanvasAPI.Team

  @valid_attrs %{domain: "usecanvas.com", name: "Canvas", slack_id: "FOOBAR"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Team.changeset(%Team{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Team.changeset(%Team{}, @invalid_attrs)
    refute changeset.valid?
  end
end
