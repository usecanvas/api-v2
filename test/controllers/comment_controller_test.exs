defmodule CanvasAPI.CommentControllerTest do
  use CanvasAPI.ConnCase

  import CanvasAPI.Factory

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe ".create/2" do
    test "creates a comment from valid attributes", %{conn: conn} do
      block = build(:block, content: "Hello, world")
      canvas = insert(:canvas, blocks: [block])
      block = List.first(canvas.blocks)
      account = canvas.creator.account

      data = %{
        data: %{
          attributes: %{
            blocks: [%{
              type: "paragraph",
              content: "Hello, World"
            }]
          },
          relationships: %{
            canvas: %{data: %{type: "canvas", id: canvas.id}},
            block: %{data: %{type: "block", id: block.id}}
          }
        }
      }

      conn =
        conn
        |> put_private(:current_account, account)
        |> post(comment_path(conn, :create), data)

      assert json_response(conn, 201)["data"]
    end
  end
end
