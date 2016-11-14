defmodule CanvasAPI.MarkdownTest do
  use ExUnit.Case, async: true

  alias CanvasAPI.Markdown

  test "parses a paragraph" do
    assert Markdown.parse("paragraph") ==
      [%{type: "paragraph", content: "paragraph"}]
  end

  test "parses a heading-like paragraph" do
    assert Markdown.parse("\n####### paragraph") ==
      [%{type: "paragraph", content: "####### paragraph"}]
  end

  test "parses a level 1 heading" do
    assert Markdown.parse("\n# Heading") ==
      [%{type: "heading", content: "Heading", meta: %{level: 1}}]
  end

  test "parses a level 2 heading" do
    assert Markdown.parse("\n## Heading") ==
      [%{type: "heading", content: "Heading", meta: %{level: 2}}]
  end

  test "parses a level 3 heading" do
    assert Markdown.parse("\n### Heading") ==
      [%{type: "heading", content: "Heading", meta: %{level: 3}}]
  end

  test "parses a level 4 heading" do
    assert Markdown.parse("\n#### Heading") ==
      [%{type: "heading", content: "Heading", meta: %{level: 4}}]
  end

  test "parses a level 5 heading" do
    assert Markdown.parse("\n##### Heading") ==
      [%{type: "heading", content: "Heading", meta: %{level: 5}}]
  end

  test "parses a level 6 heading" do
    assert Markdown.parse("\n###### Heading") ==
      [%{type: "heading", content: "Heading", meta: %{level: 6}}]
  end

  test "parses a horizontal rule" do
    assert Markdown.parse("- - - -") == [%{type: "horizontal-rule"}]
    assert Markdown.parse("-") == [%{type: "horizontal-rule"}]
    assert Markdown.parse("---") == [%{type: "horizontal-rule"}]
    assert Markdown.parse("-  -  -") == [%{type: "horizontal-rule"}]
  end

  test "parses a title" do
    assert Markdown.parse("# Title") ==
      [%{type: "title", content: "Title"}]
  end

  test "parses an image" do
    url = "https://example.com/foo.png"
    assert Markdown.parse(url) ==
      [%{type: "image", meta: %{url: url}}]
  end

  test "parses a URL" do
    url = "https://example.com/foo"
    assert Markdown.parse(url) ==
      [%{type: "url", meta: %{url: url}}]
  end

  test "parses a checklist item" do
    assert Markdown.parse("* [x] Foo") ==
      [%{type: "list",
         blocks: [%{
           type: "checklist-item",
           content: "Foo",
           meta: %{
             level: 1,
             checked: true}}]}]
  end

  test "parses an unordered list item" do
    assert Markdown.parse("- Foo") ==
      [%{type: "list",
         blocks: [%{
           type: "unordered-list-item",
           content: "Foo",
           meta: %{
             level: 1}}]}]
  end

  test "parses a multi-item list" do
    assert Markdown.parse("* [x] Foo\n  - Bar\n- [ ] Baz") ==
      [%{
        type: "list",
        blocks: [%{
          type: "checklist-item",
          content: "Foo",
          meta: %{level: 1, checked: true}
        }, %{
          type: "unordered-list-item",
          content: "Bar",
          meta: %{level: 2}
        }, %{
          type: "checklist-item",
          content: "Baz",
          meta: %{level: 1, checked: false}
        }]
      }]
  end

  test "parses an paragraph following a list" do
    assert Markdown.parse("* [x] Foo\n  - Bar\nBaz") ==
      [%{
        type: "list",
        blocks: [%{
          type: "checklist-item",
          content: "Foo",
          meta: %{level: 1, checked: true}
        }, %{
          type: "unordered-list-item",
          content: "Bar",
          meta: %{level: 2}
        }]
      }, %{
        type: "paragraph",
        content: "Baz"
      }]
  end

  test "parses code" do
    assert Markdown.parse("```js\nfoo\nbar\n```") ==
      [%{
        type: "code",
        content: "foo\nbar",
        meta: %{language: "js"}
      }]
  end

  test "parses code with no language" do
    assert Markdown.parse("```\nfoo\nbar\n```") ==
      [%{
        type: "code",
        content: "foo\nbar",
        meta: %{language: nil}
      }]
  end

  test "parses un-terminated code" do
    assert Markdown.parse("```\nfoo\nbar") ==
      [%{
        type: "code",
        content: "foo\nbar",
        meta: %{language: nil}
      }]
  end

  test "parses items after code" do
    assert Markdown.parse("```ruby\nfoo\n  bar\n```\nFoo") ==
      [%{
        type: "code",
        content: "foo\n  bar",
        meta: %{language: "ruby"}
      }, %{
        type: "paragraph",
        content: "Foo"
      }]
  end

  test "parses tab-indented code" do
    assert Markdown.parse("	foo\n	  bar\n	baz\nqux") ==
      [%{
        type: "code",
        content: "foo\n  bar\nbaz",
        meta: %{language: nil}
      }, %{
        type: "paragraph",
        content: "qux"
      }]
  end

  test "parses a complex Markdown document" do
    parsed = Markdown.parse """
    # Title

    Paragraph.

    ## Heading 1

    - Foo
      - [ ] Bar
      - [x] Baz

    ```elixir
    defmodule Foo do
      @type t :: %__MODULE__{}
    end
    ```

    \tdefmodule Foo do
    \t  @type t :: %__MODULE__{}
    \tend

        defmodule Foo do
          @type t :: %__MODULE__{}
        end

    ---

    ## Heading 2

    https://example.com/foo.png
    http://example.com/foo
    """

    assert parsed == [%{
      type: "title",
      content: "Title"
    }, %{
      type: "paragraph",
      content: "Paragraph."
    }, %{
      type: "heading",
      content: "Heading 1",
      meta: %{level: 2}
    }, %{
      type: "list",
      blocks: [%{
        type: "unordered-list-item",
        content: "Foo",
        meta: %{level: 1}
      }, %{
        type: "checklist-item",
        content: "Bar",
        meta: %{level: 2, checked: false}
      }, %{
        type: "checklist-item",
        content: "Baz",
        meta: %{level: 2, checked: true}
      }]
    }, %{
      type: "code",
      content: """
      defmodule Foo do
        @type t :: %__MODULE__{}
      end\
      """,
      meta: %{language: "elixir"}
    }, %{
      type: "code",
      content: """
      defmodule Foo do
        @type t :: %__MODULE__{}
      end\
      """,
      meta: %{language: nil}
    }, %{
      type: "code",
      content: """
      defmodule Foo do
        @type t :: %__MODULE__{}
      end\
      """,
      meta: %{language: nil}
    }, %{
      type: "horizontal-rule"
    }, %{
      type: "heading",
      content: "Heading 2",
      meta: %{level: 2}
    }, %{
      type: "image",
      meta: %{url: "https://example.com/foo.png"}
    }, %{
      type: "url",
      meta: %{url: "http://example.com/foo"}
    }]
  end
end
