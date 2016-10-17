defmodule CanvasAPI.Unfurl.CanvasTest do
  use CanvasAPI.ModelCase

  alias CanvasAPI.Block
  alias CanvasAPI.Unfurl.Canvas, as: UnfurlCanvas
  import CanvasAPI.Factory

  @tag :focus
  test "unfurls fijltered URLs" do
    canvas = insert(:canvas, blocks: [
      %Block{content: "Foo", type: "paragraph"},
      %Block{content: "Bar", type: "paragraph"}])
    url = "/#{canvas.team.domain}/#{canvas.id}?filter=bar"
    assert UnfurlCanvas.unfurl(url).text == "Bar"
  end
end
