defmodule CanvasAPI.OAuthTokenTest do
  use CanvasAPI.ModelCase

  alias CanvasAPI.OAuthToken

  @valid_attrs %{meta: %{}, provider: "some content", token: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = OAuthToken.changeset(%OAuthToken{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = OAuthToken.changeset(%OAuthToken{}, @invalid_attrs)
    refute changeset.valid?
  end
end
