defmodule CanvasAPI.TeamService do
  @moduledoc """
  A service for viewing and manipulating teams.
  """

  use CanvasAPI.Web, :service
  alias CanvasAPI.{Account, Team}
  import CanvasAPI.UUIDMatch

  @preload [:oauth_tokens]

  @doc """
  List teams for a given account.

  Options:

  - `filter`: `map` A string-keyed filter map
    - `domain`: `String.t` A domain to filter teams by

  ## Examples

  ```elixir
  TeamService.list(account, filter: %{"domain" => "usecanvas"})
  ```
  """
  @spec list(%Account{}, Keyword.t) :: [%Team{}]
  def list(account, opts) do
    from(assoc(account, :teams),
         order_by: [fragment("slack_id NULLS FIRST"), :name],
         preload: ^@preload)
    |> filter(opts[:filter])
    |> Repo.all
  end

  @doc """
  Show a specific team by ID or domain.

  ## Examples

  ```elixir
  TeamService.show("usecanvas")
  ```
  """
  @spec show(String.t) :: {:ok, %Team{}} | {:error, :not_found}
  def show(id) do
    from(Team, preload: ^@preload)
    |> do_get(id)
  end

  @spec do_get(Ecto.Queryable.t, String.t) :: {:ok, %Team{}}
                                            | {:error, :not_found}
  defp do_get(queryable, id = match_uuid()) do
    Repo.get(queryable, id)
    |> case do
      nil -> {:error, :not_found}
      team -> {:ok, team}
    end
  end

  defp do_get(queryable, domain) do
    queryable
    |> where(domain: ^domain)
    |> Repo.one
    |> case do
      nil -> {:error, :not_found}
      team -> {:ok, team}
    end
  end

  @doc """
  Find the user associated with `team` for `account` and add it to `team` as
  `account_user`.

  ## Examples

  ```elixir
  TeamService.add_account_user(team, account)
  ```
  """
  @spec add_account_user(%Team{}, %Account{} | nil) :: %Team{}
  def add_account_user(team, nil), do: Map.put(team, :account_user, nil)
  def add_account_user(team, account) do
    user =
      from(assoc(account, :users),
           where: [team_id: ^team.id])
      |> Repo.one
    Map.put(team, :account_user, user)
  end

  @spec filter(Ecto.Queryable.t, map | nil) :: [%Team{}]
  defp filter(queryable, %{"domain" => domain}),
    do: where(queryable, domain: ^domain)
  defp filter(queryable, _), do: queryable
end
