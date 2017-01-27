defmodule CanvasAPI.UIDismissalTest do
  use CanvasAPI.ModelCase

  alias CanvasAPI.UIDismissal
  import CanvasAPI.Factory

  @valid_attrs %{identifier: "*.23423432323.foo"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = UIDismissal.changeset(%UIDismissal{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = UIDismissal.changeset(%UIDismissal{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "validates unique identifiers per account" do
    dismissal = insert(:ui_dismissal)

    {:error, changeset} =
      %CanvasAPI.UIDismissal{}
      |> CanvasAPI.UIDismissal.changeset(%{identifier: dismissal.identifier})
      |> Ecto.Changeset.put_assoc(:account, dismissal.account)
      |> CanvasAPI.Repo.insert

    assert {:identifier, {"has already been taken", []}} in changeset.errors
  end
end
