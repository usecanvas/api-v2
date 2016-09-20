defmodule CanvasAPI.ImageMapTest do
  use ExUnit.Case, async: true

  alias CanvasAPI.ImageMap, as: IM

  test "encodes images" do
    map =
      %{"foo" => "bar", "image_1" => "one", "image_2" => "two"}
      |> IM.image_map

    assert map == %{"image_1" => "one", "image_2" => "two"}
  end
end
