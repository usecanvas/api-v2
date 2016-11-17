defmodule CanvasAPI.CanvasTest do
  use CanvasAPI.ModelCase

  alias CanvasAPI.Canvas

  @valid_attrs %{}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Canvas.changeset(%Canvas{}, @valid_attrs)
    assert changeset.valid?
  end

  describe ".changeset/2" do
    test "puts a title and paragraph if blocks are empty" do
      changeset = Canvas.changeset(%Canvas{})
      assert get_change(changeset, :blocks) |> Enum.map(&(&1.changes)) == [
        %{type: "title"},
        %{type: "paragraph"}
      ]
    end

    test "puts a title if there is no title" do
      changeset =
        Canvas.changeset(%Canvas{}, %{blocks: [%{type: "checklist-item"}]})
      assert get_change(changeset, :blocks) |> Enum.map(&(&1.changes)) == [
        %{type: "title"},
        %{type: "checklist-item"}
      ]
    end

    test "puts a paragraph is there is only a title" do
      changeset =
        Canvas.changeset(%Canvas{}, %{blocks: [%{type: "title"}]})
      assert get_change(changeset, :blocks) |> Enum.map(&(&1.changes)) == [
        %{type: "title"},
        %{type: "paragraph"}
      ]
    end

    test "changes nothing if a title and content block are present" do
      changeset =
        Canvas.changeset(%Canvas{},
                         %{blocks: [%{type: "title"}, %{type: "paragraph"}]})
      assert get_change(changeset, :blocks) |> Enum.map(&(&1.changes)) == [
        %{type: "title"},
        %{type: "paragraph"}
      ]
    end
  end
end
