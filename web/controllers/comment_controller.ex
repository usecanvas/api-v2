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

  @doc """
  Respond to a request for a single comment.
  """
  @spec show(Plug.Conn.t, Plug.Conn.params) :: Plug.Conn.t
  def show(conn = %{private: %{parsed_request: parsed_request}}, _) do
    parsed_request.id
    |> CommentService.get(parsed_request.opts)
    |> case do
      {:ok, comment} ->
        render(conn, "show.json", comment: comment)
      {:error, :comment_not_found} ->
        not_found(conn, detail: "Comment not found")
    end
  end

  @doc """
  Respond to a request to update a comment.
  """
  @spec update(Plug.Conn.t, Plug.Conn.params) :: Plug.Conn.t
  def update(conn = %{private: %{parsed_request: parsed_request}}, _) do
    parsed_request.id
    |> CommentService.update(parsed_request.attrs, parsed_request.opts)
    |> case do
      {:ok, comment} ->
        render(conn, "show.json", comment: comment)
      {:error, :comment_not_found} ->
        not_found(conn, detail: "Comment not found")
      {:error, :does_not_own} ->
        forbidden(conn)
      {:error, changeset} ->
        unprocessable_entity(conn, changeset)
    end
  end

  @doc """
  Respond to a request to delete a comment.
  """
  @spec delete(Plug.Conn.t, Plug.Conn.params) :: Plug.Conn.t
  def delete(conn = %{private: %{parsed_request: parsed_request}}, _) do
    parsed_request.id
    |> CommentService.delete(parsed_request.opts)
    |> case do
      {:ok, _} ->
        no_content(conn)
      {:error, :comment_not_found} ->
        not_found(conn, detail: "Comment not found")
    end
  end
end
