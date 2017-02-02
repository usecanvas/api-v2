defmodule CanvasAPI.ThreadSubscriptionTest do
  use CanvasAPI.ModelCase, async: true

  alias CanvasAPI.ThreadSubscription

  @valid_attrs %{subscribed: true}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = ThreadSubscription.changeset(%ThreadSubscription{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = ThreadSubscription.changeset(%ThreadSubscription{}, @invalid_attrs)
    refute changeset.valid?
  end
end
