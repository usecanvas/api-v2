defmodule CanvasAPI.UserTest do
  use CanvasAPI.ModelCase

  alias CanvasAPI.User

  @valid_attrs %{email: "user@example.com", identity_token: "some content", name: "Jonathan", slack_id: "FOOBAR"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = User.changeset(%User{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = User.changeset(%User{}, @invalid_attrs)
    refute changeset.valid?
  end
end
