defmodule CanvasAPI.WatchedCanvasService do
  @moduledoc """
  A service for viewing and manipulating watched canvases.
  """

  use CanvasAPI.Web, :service

  alias CanvasAPI.{Canvas, CanvasService, Team, User, UserService,
                   WatchedCanvas}

  @preload [:user, canvas: [:team]]

  @doc """
  Insert a new watched canvas.
  """
  @spec insert(attrs, Keyword.t) :: {:ok, WatchedCanvas.t}
                                  | {:error, Changeset.t}
  def insert(attrs, opts) do
    %WatchedCanvas{}
    |> WatchedCanvas.changeset(attrs)
    |> put_canvas(attrs["canvas_id"], opts[:account])
    |> put_user(opts[:account])
    |> Repo.insert
  end

  @spec put_canvas(Changeset.t, String.t | nil, Account.t) :: Changeset.t
  defp put_canvas(changeset, id, account) when is_binary(id) do
    id
    |> CanvasService.get(account: account)
    |> case do
      {:ok, canvas} ->
        put_assoc(changeset, :canvas, canvas)
      {:error, _} ->
        add_error(changeset, :canvas, "was not found")
    end
  end

  defp put_canvas(changeset, _, _),
    do: add_error(changeset, :canvas, "is required")

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
  Get a watched canvas by ID.
  """
  @spec get(String.t, Keyword.t) :: {:ok, WatchedCanvas.t}
                                  | {:error, :watch_not_found}
  def get(id, opts) do
    opts[:account].id
    |> watch_query
    |> maybe_lock
    |> where(canvas_id: ^id)
    |> Repo.one
    |> case do
      watch = %WatchedCanvas{} ->
        {:ok, watch}
      nil ->
        {:error, :watch_not_found}
    end
  end

  @doc """
  Delete a watched canvas.
  """
  @spec delete(String.t, Keyword.t) :: {:ok, WatchedCanvas.t}
                                     | {:error, :watch_not_found}
  def delete(id, opts) do
    Repo.transaction(fn ->
      with {:ok, watch} <- get(id, opts) do
        Repo.delete(watch)
      end
      |> case do
        {:ok, watch} -> watch
        {:error, error} -> Repo.rollback(error)
      end
    end)
  end

  @spec watch_query(String.t) :: Ecto.Query.t
  defp watch_query(account_id) do
    WatchedCanvas
    |> join(:left, [w], c in Canvas, w.canvas_id == c.id)
    |> join(:left, [..., c], t in Team, c.team_id == t.id)
    |> join(:left, [..., t], u in User, u.team_id == t.id)
    |> where([..., u], u.account_id == ^account_id)
    |> preload(^@preload)
  end
end
