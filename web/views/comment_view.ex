defmodule CanvasAPI.CommentView do
  @moduledoc """
  A view for rendering comments.
  """

  alias CanvasAPI.{Endpoint, UserView}
  use CanvasAPI.Web, :view

  def render("index.json", %{comments: comments}) do
    %{
      data: render_many(comments, __MODULE__, "comment.json"),
      included: Enum.map(comments, &include_comment_creator/1)
    }
  end

  def render("show.json", %{comment: comment}) do
    %{
      data: render_one(comment, __MODULE__, "comment.json"),
      included: [include_comment_creator(comment)]
    }
  end

  def render("comment.json", %{comment: comment}) do
    %{
      id: comment.id,
      attributes: %{
        blocks: comment.blocks,
        inserted_at: comment.inserted_at,
        updated_at: comment.updated_at
      },
      relationships: %{
        block: %{data: %{id: comment.block_id, type: "block"}},
        canvas: %{
          data: %{id: comment.canvas_id, type: "canvas"},
          links: %{
            related: team_canvas_path(Endpoint, :show,
                                      comment.canvas.team_id, comment.canvas.id)
          }
        },
        creator: %{data: %{id: comment.creator_id, type: "user"}}
      },
      type: "comment"
    }
  end

  defp include_comment_creator(comment = %{creator: creator}) do
    creator
    |> Map.put(:team, comment.canvas.team)
    |> render_one(UserView, "user.json")
  end
end
