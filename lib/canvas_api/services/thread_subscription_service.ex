defmodule CanvasAPI.ThreadSubscriptionService do
  @moduledoc """
  A service for viewing and manipulating thread subscriptions.
  """

  use CanvasAPI.Web, :service

  alias CanvasAPI.{Account, Canvas, CanvasService, ThreadSubscription,
                   UserService}

  @preload [:user, canvas: [:team]]

  @doc """
  Create or update a thread subscription.
  """
  @spec upsert(String.t, attrs, Keyword.t) :: {:ok, ThreadSubscription.t}
                                            | {:error, Changeset.t}
  def upsert(block_id, attrs, opts) do
    %ThreadSubscription{}
    |> ThreadSubscription.changeset(attrs)
    |> put_canvas(attrs["canvas_id"], opts[:account])
    |> put_block(block_id)
    |> put_user(opts[:account])
    |> Repo.insert(on_conflict: [set: [subscribed: attrs["subscribed"]]],
                   conflict_target: [:user_id, :canvas_id, :block_id])
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

  @spec put_user(Changeset.t, Account.t) :: Changeset.t
  defp put_user(changeset, account) do
    with canvas = %Canvas{} <- get_field(changeset, :canvas) do
      {:ok, user} = UserService.find_by_team(account, team_id: canvas.team_id)
      put_assoc(changeset, :user, user)
    else
        _ -> changeset
    end
  end

  @doc """
  List thread subscriptinos.
  """
  @spec list(Keyword.t) :: [ThreadSubscription.t]
  def list(opts) do
    opts[:account]
    |> thread_subscription_query
    |> filter(opts[:filter])
    |> Repo.all
  end

  @spec filter(Ecto.Query.t, map | nil) :: Ecto.Query.t
  defp filter(query, filter) when is_map(filter),
    do: Enum.reduce(filter, query, &do_filter/2)
  defp filter(query, _),
    do: query

  @spec do_filter({String.t, String.t}, Ecto.Query.t) :: Ecto.Query.t
  defp do_filter({"canvas.id", canvas_id}, query),
    do: where(query, canvas_id: ^canvas_id)
  defp do_filter({"block.id", block_id}, query),
    do: where(query, block_id: ^block_id)
  defp do_filter(_, query), do: query

  @spec thread_subscription_query(Account.t) :: Ecto.Query.t
  defp thread_subscription_query(account) do
    account
    |> assoc(:thread_subscriptions)
    |> preload(^@preload)
  end
end
