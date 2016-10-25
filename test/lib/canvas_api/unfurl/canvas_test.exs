defmodule CanvasAPI.Unfurl.CanvasTest do
  use CanvasAPI.ModelCase

  alias CanvasAPI.Canvas
  alias CanvasAPI.Unfurl.Canvas, as: UnfurlCanvas
  alias CanvasAPI.Unfurl.Field

  import CanvasAPI.Factory

  test "unfurls filtered URLs" do
    canvas = insert(:canvas, blocks: [
      build(:title_block, content: "Title"),
      build(:block, content: "Foo"),
      build(:block, content: "Bar")])
    url = Canvas.web_url(canvas) <> "?filter=bar"
    unfurl = UnfurlCanvas.unfurl(url)
    assert unfurl.title == "Title"
    assert unfurl.text == "Bar"
  end

  test "unfurls lists" do
    canvas = insert(:canvas, blocks: [
      build(:title_block, content: "Title"),
      build(:block, content: "First Paragraph"),
      build(:list_block, blocks: [
        build(:ul_block, content: "UL Item"),
        build(:cl_block, meta: %{"checked" => false}),
        build(:cl_block, meta: %{"checked" => true})
      ])
    ])

    list = List.last(canvas.blocks)

    url = Canvas.web_url(canvas) <> "?block=#{list.id}"
    unfurl = UnfurlCanvas.unfurl(url)
    assert unfurl.title == "Title"
    assert unfurl.text == "UL Item"
    assert unfurl.fields == [
      %Field{short: true, title: "Tasks Complete", value: 1},
      %Field{short: true, title: "Tasks Total", value: 2}]
  end

  test "unfurls filtered lists" do
    canvas = insert(:canvas, blocks: [
      build(:title_block, content: "Title"),
      build(:block, content: "First Paragraph"),
      build(:list_block, blocks: [
        build(:ul_block, content: "UL Item"),
        build(:cl_block, meta: %{"checked" => false}),
        build(:cl_block, meta: %{"checked" => true})
      ])
    ])

    list = List.last(canvas.blocks)

    url = Canvas.web_url(canvas) <> "?filter=UL" <> "&block=#{list.id}"
    unfurl = UnfurlCanvas.unfurl(url)
    assert unfurl.title == "Title"
    assert unfurl.text == "UL Item"
    assert unfurl.fields == [
      %Field{short: true, title: "Tasks Complete", value: 0},
      %Field{short: true, title: "Tasks Total", value: 0}]
  end

  test "unfurls sections" do
    canvas = insert(:canvas, blocks: [
      build(:title_block, content: "Title"),
      build(:block, content: "First Paragraph"),
      build(:heading_block, content: "Section 1"),
      build(:heading_block, content: "Sub-Section", meta: %{"level" => 2}),
      build(:block, content: "Section Paragraph"),
      build(:heading_block, content: "Sub-Section", meta: %{"level" => 2}),
      build(:list_block, blocks: [
        build(:ul_block, content: "UL Item"),
        build(:cl_block, meta: %{"checked" => false}),
        build(:cl_block, meta: %{"checked" => true})
      ]),
      build(:heading_block, content: "Section 2"),
      build(:list_block, blocks: [
        build(:ul_block, content: "UL Item"),
        build(:cl_block, meta: %{"checked" => true})
      ]),
    ])

    heading = Enum.at(canvas.blocks, 2)
    unfurl =
      Canvas.web_url(canvas) <> "?block=#{heading.id}" |> UnfurlCanvas.unfurl
    assert unfurl.title == "Section 1"
    assert unfurl.text == "Section Paragraph"
    assert unfurl.fields == [
      %Field{short: true, title: "Tasks Complete", value: 1},
      %Field{short: true, title: "Tasks Total", value: 2}]
  end

  test "unfurls filtered sections" do
    canvas = insert(:canvas, blocks: [
      build(:title_block, content: "Title"),
      build(:block, content: "First Paragraph"),
      build(:heading_block, content: "UL Section 1"),
      build(:block, content: "Section Paragraph"),
      build(:heading_block, content: "Sub-Section", meta: %{"level" => 2}),
      build(:list_block, blocks: [
        build(:ul_block, content: "UL Item"),
        build(:cl_block, meta: %{"checked" => false}),
        build(:cl_block, meta: %{"checked" => true})
      ]),
      build(:heading_block, content: "Section 2"),
      build(:list_block, blocks: [
        build(:ul_block, content: "UL Item"),
        build(:cl_block, meta: %{"checked" => true})
      ]),
    ])

    heading = Enum.at(canvas.blocks, 2)
    unfurl =
      Canvas.web_url(canvas) <> "?filter=UL" <> "&block=#{heading.id}"
      |> UnfurlCanvas.unfurl
    assert unfurl.title == "UL Section 1"
    assert unfurl.text == "UL Item"
    assert unfurl.fields == [
      %Field{short: true, title: "Tasks Complete", value: 0},
      %Field{short: true, title: "Tasks Total", value: 0}]
  end
end
