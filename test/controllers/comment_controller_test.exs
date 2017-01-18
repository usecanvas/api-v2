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

  describe ".index/2" do
    test "lists comments", %{conn: conn} do
      comment = insert(:comment)
      conn =
        conn
        |> put_private(:current_account, comment.creator.account)
        |> get(comment_path(conn, :index))

      assert get_in(json_response(conn, 200), ["data", Access.at(0), "id"]) ==
        comment.id
    end

    test "lists comments filtered by canvas", %{conn: conn} do
      canvas = insert(:canvas)
      comment = insert(:comment, canvas: canvas)
      canvas_2 = insert(:canvas, team: canvas.team)
      insert(:comment, canvas: canvas_2)

      conn =
        conn
        |> put_private(:current_account, canvas.creator.account)
        |> get(comment_path(conn, :index), filter: %{"canvas.id" => canvas.id})

      [listed_comment] = json_response(conn, 200)["data"]
      assert listed_comment["id"] == comment.id
    end
  end

  describe ".show/2" do
    test "shows the requested comment", %{conn: conn} do
      canvas = insert(:canvas)
      comment = insert(:comment, canvas: canvas, creator: canvas.creator)

      conn =
        conn
        |> put_private(:current_account, comment.creator.account)
        |> get(comment_path(conn, :show, comment))

      assert json_response(conn, 200)
    end
  end

  describe ".delete/2" do
    test "deletes the requested comment", %{conn: conn} do
      canvas = insert(:canvas)
      comment = insert(:comment, canvas: canvas, creator: canvas.creator)

      conn =
        conn
        |> put_private(:current_account, comment.creator.account)
        |> delete(comment_path(conn, :show, comment))

      assert response(conn, 204) == ""
      refute Repo.reload(comment)
    end
  end

  describe ".update/2" do
    test "updates a comment from valid attributes", %{conn: conn} do
      canvas = insert(:canvas)
      comment = insert(:comment, canvas: canvas, creator: canvas.creator)
      data = %{
        attributes: %{
          blocks: [%{type: "paragraph", content: "New content"}]
        }
      }

      conn =
        conn
        |> put_private(:current_account, comment.creator.account)
        |> patch(comment_path(conn, :update, comment), %{data: data})

      assert json_response(conn, 200)
      assert Repo.reload(comment).blocks |> Enum.map(&(&1.content)) ==
        ["New content"]
    end

    test "returns a 404 when a comment isn't found", %{conn: conn} do
      comment = insert(:comment)

      conn =
        conn
        |> put_private(:current_account, insert(:account))
        |> patch(comment_path(conn, :update, comment), %{data: %{}})

      assert json_response(conn, 404)
    end
  end
end
