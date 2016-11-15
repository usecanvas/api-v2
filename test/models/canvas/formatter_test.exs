defmodule CanvasAPI.Canvas.FormatterTest do
  use ExUnit.Case, async: true

  alias CanvasAPI.{Block, Canvas}
  alias CanvasAPI.Canvas.Formatter, as: CanvasFormatter

  describe ".to_markdown/1" do
    test "converts a canvas to Markdown" do
      canvas = %Canvas{
        blocks: [%Block{
          type: "title",
          content: "Title"
        }, %Block{
          type: "paragraph",
          content: "Paragraph content."
        }, %Block{
          type: "list",
          blocks: [%Block{
            type: "unordered-list-item",
            content: "Foo",
            meta: %{"level" => 1}
          }, %Block{
            type: "unordered-list-item",
            content: "Bar",
            meta: %{"level" => 1}
          }, %Block{
            type: "checklist-item",
            content: "Baz",
            meta: %{"level" => 2, "checked" => false}
          }, %Block{
            type: "checklist-item",
            content: "Qux",
            meta: %{"level" => 2, "checked" => true}
          }]
        }, %Block{
          type: "horizontal-rule"
        }, %Block{
          type: "heading",
          content: "Smaller Heading",
          meta: %{"level" => 3}
        }, %Block{
          type: "url",
          meta: %{"url" => "https://example.com"}
        }, %Block{
          type: "code",
          content: "Foo\n  Bar\nBaz",
          meta: %{"language" => nil}
        }, %Block{
          type: "code",
          content: "Foo\n  Bar\nBaz",
          meta: %{"language" => "elixir"}
        }, %Block{
          type: "image",
          meta: %{"url" => "https://example.com/foo.png"}
        }]
      }

      assert CanvasFormatter.to_markdown(canvas) == String.trim_trailing("""
      # Title

      Paragraph content.

      - Foo
      - Bar
        - [ ] Baz
        - [x] Qux

      ---

      ### Smaller Heading

      <https://example.com>

      ```
      Foo
        Bar
      Baz
      ```

      ```elixir
      Foo
        Bar
      Baz
      ```

      ![](https://example.com/foo.png)
      """)
    end
  end
end
