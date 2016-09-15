defmodule CanvasAPI.AccountTest do
  use CanvasAPI.ModelCase

  alias CanvasAPI.Account

  @valid_attrs %{email: "user@example.com", slack_id: "U0123456789"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Account.changeset(%Account{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Account.changeset(%Account{}, @invalid_attrs)
    refute changeset.valid?
  end
end
