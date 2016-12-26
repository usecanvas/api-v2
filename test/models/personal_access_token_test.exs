defmodule CanvasAPI.PersonalAccessTokenTest do
  use CanvasAPI.ModelCase

  alias CanvasAPI.PersonalAccessToken

  @valid_attrs %{encrypted_token: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = PersonalAccessToken.changeset(%PersonalAccessToken{}, @valid_attrs)
    assert changeset.valid?
  end

  # test "changeset with invalid attributes" do
    # changeset = PersonalAccessToken.changeset(%PersonalAccessToken{}, @invalid_attrs)
    # refute changeset.valid?
  # end
end
