defmodule CanvasAPI.WhitelistedSlackDomainTest do
  use CanvasAPI.ModelCase

  alias CanvasAPI.WhitelistedSlackDomain

  @valid_attrs %{domain: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = WhitelistedSlackDomain.changeset(%WhitelistedSlackDomain{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = WhitelistedSlackDomain.changeset(%WhitelistedSlackDomain{}, @invalid_attrs)
    refute changeset.valid?
  end
end
