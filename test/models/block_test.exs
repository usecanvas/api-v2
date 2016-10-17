defmodule CanvasAPI.BlockTest do
  use ExUnit.Case, async: true

  alias CanvasAPI.Block

  describe ".matches_filter?/2" do
    test "filters based on URL for a URL block" do
      block = %Block{meta: %{"url" => "Foo"}, type: "url"}
      assert Block.matches_filter?(block, "foo")
      refute Block.matches_filter?(block, "bar")
    end

    test "filters list based on inner blocks" do
      url = %Block{meta: %{"url" => "Foo"}, type: "url"}
      block = %Block{blocks: [url], type: "list"}
      assert Block.matches_filter?(block, "foo")
      refute Block.matches_filter?(block, "bar")
    end

    test "filters based on content for non-URL blocks" do
      block = %Block{content: "Foo", type: "paragraph"}
      assert Block.matches_filter?(block, "foo")
      refute Block.matches_filter?(block, "bar")
    end
  end
end
