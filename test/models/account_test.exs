defmodule CanvasAPI.AccountTest do
  use CanvasAPI.ModelCase

  alias CanvasAPI.Account

  @valid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Account.changeset(%Account{}, @valid_attrs)
    assert changeset.valid?
  end
end
