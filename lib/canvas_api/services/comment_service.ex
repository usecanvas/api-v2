defmodule CanvasAPI.CommentService do
  @moduledoc """
  A service for viewing and manipulating comments.
  """

  alias CanvasAPI.{Account, Canvas, CanvasService, Comment,
                   SlackNotifier, Team, User, UserService}
  alias Ecto.Changeset
  use CanvasAPI.Web, :service

  @preload [:creator, canvas: [:team]]

  @doc """
  Create a new comment on a given block and block.
  """
  @spec create(map, Keyword.t) :: {:ok, Comment.t} | {:error, Changeset.t}
  def create(attrs, opts) do
    %Comment{}
    |> Comment.changeset(attrs)
    |> put_canvas(attrs["canvas_id"], opts[:account])
    |> put_block(attrs["block_id"])
    |> put_creator(opts[:account])
    |> Repo.insert
    |> case do
      {:ok, comment} ->
        notify_comment(comment, "new_comment")
        {:ok, comment}
      error ->
        error
    end
  end

  @spec put_block(Changeset.t, String.t | nil) :: Changeset.t
  defp put_block(changeset, id) when is_binary(id) do
    with canvas when not is_nil(canvas) <- get_field(changeset, :canvas),
         block  when not is_nil(block)  <- Canvas.find_block(canvas, id) do
      put_change(changeset, :block_id, id)
    else
      _ -> add_error(changeset, :block, "was not found")
    end
  end

  defp put_block(changeset, _),
    do: add_error(changeset, :block, "is required")

  @spec put_canvas(Changeset.t, String.t | nil, Account.t) :: Changeset.t
  defp put_canvas(changeset, id, account) when is_binary(id) do
    id
    |> CanvasService.get(account: account)
    |> case do
      {:ok, canvas} ->
        changeset |> put_assoc(:canvas, canvas)
      {:error, _} ->
        changeset |> add_error(:canvas, "was not found")
    end
  end

  defp put_canvas(changeset, _, _),
    do: changeset |> add_error(:canvas, "is required")

  @spec put_creator(Changeset.t, Account.t) :: Changeset.t
  defp put_creator(changeset, account) do
    with canvas when not is_nil(canvas) <- get_field(changeset, :canvas) do
      {:ok, user} = UserService.find_by_team(account, team_id: canvas.team_id)
      put_assoc(changeset, :creator, user)
    else
      _ -> changeset
    end
  end

  @doc """
  Retrieve a single comment by ID.
  """
  @spec get(String.t, Keyword.t) :: {:ok, Comment.t}
                                  | {:error, :comment_not_found}
  def get(id, opts) do
    opts[:account].id
    |> comment_query
    |> maybe_lock
    |> where(id: ^id)
    |> Repo.one
    |> case do
      comment = %Comment{} ->
        {:ok, comment}
      nil ->
        {:error, :comment_not_found}
    end
  end

  @doc """
  List comments.
  """
  @spec list(Keyword.t) :: [Comment.t]
  def list(opts) do
    opts[:account].id
    |> comment_query
    |> filter(opts[:filter])
    |> Repo.all
  end

  @spec filter(Ecto.Query.t, map | nil) :: Ecto.Query.t
  defp filter(query, filter) when is_map(filter) do
    filter
    |> Enum.reduce(query, &do_filter/2)
  end

  defp filter(query, _), do: query

  @spec do_filter({String.t, String.t}, Ecto.Query.t) :: Ecto.Query.t
  defp do_filter({"canvas.id", canvas_id}, query),
    do: where(query, canvas_id: ^canvas_id)
  defp do_filter({"block.id", block_id}, query),
    do: where(query, block_id: ^block_id)
  defp do_filter(_, query), do: query

  @doc """
  Update a comment.
  """
  @spec update(String.t | Comment.t, map, Keyword.t)
        :: {:ok, Comment.t}
         | {:error, Changeset.t | :comment_not_found | :does_not_own}
  def update(id, attrs, opts \\ [])

  def update(id, attrs, opts) when is_binary(id) do
    Repo.transaction fn ->
      with {:ok, comment} <- get(id, opts) do
        __MODULE__.update(comment, attrs, opts)
      end
      |> case do
        {:ok, comment} -> comment
        {:error, error} -> Repo.rollback(error)
      end
    end
  end

  def update(comment, attrs, opts) do
    if opts[:account].id == comment.creator.account_id do
      comment
      |> Comment.changeset(attrs)
      |> Repo.update
      |> case do
        {:ok, comment} ->
          notify_comment(comment, "updated_comment")
          {:ok, comment}
        error -> error
      end
    else
      {:error, :does_not_own}
    end
  end

  @doc """
  Delete a comment.
  """
  @spec delete(String.t | Comment.t, Keyword.t) :: {:ok, Comment.t}
                                                 | {:error, :comment_not_found}
  def delete(id, opts \\ [])

  def delete(id, opts) when is_binary(id) do
    Repo.transaction fn ->
      with {:ok, comment} <- get(id, opts) do
        __MODULE__.delete(comment, opts)
      end
      |> case do
        {:ok, comment} -> comment
        {:error, error} -> Repo.rollback(error)
      end
    end
  end

  def delete(comment, _opts) do
    comment
    |> Repo.delete
    |> case do
      {:ok, comment} ->
        notify_comment(comment, "deleted_comment")
        {:ok, comment}
      error -> error
    end
  end

  @spec comment_query(String.t) :: Ecto.Query.t
  defp comment_query(account_id) do
    Comment
    |> join(:left, [co], ca in Canvas, co.canvas_id == ca.id)
    |> join(:left, [..., ca], t in Team, ca.team_id == t.id)
    |> join(:left, [..., t], u in User, u.team_id == t.id)
    |> where([..., u], u.account_id == ^account_id)
    |> preload(^@preload)
  end

  @spec notify_comment(Comment.t, String.t) :: any
  defp notify_comment(comment, event) do
    notify_slack(comment)
    broadcast("canvas:#{comment.canvas_id}",
           event,
           "show.json",
           comment: comment)
  end

  @spec notify_slack(Comment.t) :: any
  defp notify_slack(comment) do
    with {:ok, token} <- Team.get_token(comment.canvas.team, "slack"),
         token = get_in(token.meta, ~w(bot bot_access_token)) do
      comment.canvas.slack_channel_ids
      |> Enum.each(
           &SlackNotifier.delay(
             {:notify_new_comment, [token, comment.id, &1]}))
    end
  end
end
