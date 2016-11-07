defmodule CanvasAPI.UUIDMatchTest do
  use ExUnit.Case, async: true

  require CanvasAPI.UUIDMatch

  test "matches a UUID" do
    uuid = Ecto.UUID.generate();
    assert match?(CanvasAPI.UUIDMatch.match_uuid(), uuid)
  end
end
