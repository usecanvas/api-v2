defmodule CanvasAPI.CommentController do
  @moduledoc """
  A controller for responding to comment requests.
  """

  alias CanvasAPI.CommentService
  use CanvasAPI.Web, :controller
  plug CanvasAPI.CurrentAccountPlug
  plug CanvasAPI.JSONAPIPlug

  @doc """
  Respond to a request to create a comment.
  """
  @spec create(Plug.Conn.t, Plug.Conn.params) :: Plug.Conn.t
  def create(conn = %{private: %{parsed_request: parsed_request}}, _params) do
    parsed_request.attrs
    |> CommentService.create(parsed_request.opts)
    |> case do
      {:ok, comment} ->
        created(conn, comment: comment)
      {:error, changeset} ->
        unprocessable_entity(conn, changeset)
    end
  end

  @doc """
  Respond to a request to list comments.
  """
  @spec index(Plug.Conn.t, Plug.Conn.params) :: Plug.Conn.t
  def index(conn = %{private: %{parsed_request: parsed_request}}, _) do
    comments =
      parsed_request.opts
      |> CommentService.list
    render(conn, "index.json", comments: comments)
  end
end
