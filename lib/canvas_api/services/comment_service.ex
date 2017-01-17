defmodule CanvasAPI.CommentService do
  @moduledoc """
  A service for viewing and manipulating comments.
  """

  alias CanvasAPI.{Account, Canvas, CanvasService, Comment, Repo, Team, User}
  use CanvasAPI.Web, :service

  @doc """
  Create a new comment on a given block and canvas.
  """
  @spec create(map, Keyword.t) :: {:ok, Comment.t} | {:error, Ecto.Changeset.t}
  def create(attrs, opts) do
    %Comment{}
    |> Comment.changeset(attrs)
    |> put_canvas(iget(attrs, :canvas_id), opts[:account])
    |> put_block(iget(attrs, :block_id))
    |> put_creator(opts[:account])
    |> Repo.insert
  end

  @spec put_block(Ecto.Changeset.t, String.t | nil) :: Ecto.Changeset.t
  defp put_block(changeset = %{valid?: true}, id) when is_binary(id) do
    with %{blocks: blocks} = get_change(changeset, :canvas).data,
         block when not is_nil(block) <- Enum.find(blocks, &(&1.id == id)) do
        changeset
        |> put_change(:block_id, block.id)
    else
      _ ->
        changeset
        |> add_error(:block, "was not found")
    end
  end

  defp put_block(changeset, nil) do
    changeset
    |> add_error(:block, "is required")
  end

  defp put_block(changeset, _), do: changeset

  @spec put_canvas(Ecto.Changeset.t, String.t | nil, Account.t)
        :: Ecto.Changeset.t
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

  @spec put_creator(Ecto.Changeset.t, Account.t) :: Ecto.Changeset.t
  defp put_creator(changeset = %{valid?: true}, account) do
    canvas = get_change(changeset, :canvas).data
    user =
      account
      |> assoc(:users)
      |> from(where: [team_id: ^canvas.team_id])
      |> Repo.one
    put_assoc(changeset, :creator, user)
  end

  defp put_creator(changeset, _), do: changeset

  @doc """
  List comments.
  """
  @spec list(Keyword.t) :: [Comment.t]
  def list(opts) do
    Comment
    |> join(:left, [co], ca in Canvas, co.canvas_id == ca.id)
    |> join(:left, [..., ca], t in Team, ca.team_id == t.id)
    |> join(:left, [..., t], u in User, u.team_id == t.id)
    |> where([..., u], u.account_id == ^opts[:account].id)
    |> filter(opts[:filter])
    |> Repo.all
  end

  @spec filter(Ecto.Query.t, map | nil) :: Ecto.Query.t
  defp filter(query, %{"canvas.id" => canvas_id}) do
    query
    |> where(canvas_id: ^canvas_id)
  end

  defp filter(query, _), do: query

  @spec iget(map, atom) :: any
  defp iget(map, key) do
    if Map.has_key?(map, key) do
      map[key]
    else
      map[to_string(key)]
    end
  end
end
