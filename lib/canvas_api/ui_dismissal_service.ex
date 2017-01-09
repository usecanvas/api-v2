defmodule CanvasAPI.UIDismissalService do
  @moduledoc """
  A service for viewing and manipulating UI dismissals.
  """

  use CanvasAPI.Web, :service
  alias CanvasAPI.UIDismissal

  @doc """
  List UI dismissals for an account.
  """
  @spec list(Account.t) :: [UIDismissal.t]
  def list(account) do
    from(assoc(account, :ui_dismissals))
    |> Repo.all
  end

  @doc """
  Create a UI dismissal.
  """
  @spec create(map, Keyword.t) :: {:ok, UIDismissal.t}
                                | {:error, Ecto.Changeset.t}
  def create(params, opts) do
    %UIDismissal{}
    |> UIDismissal.changeset(params)
    |> put_assoc(:account, opts[:account])
    |> Repo.insert
  end
end
