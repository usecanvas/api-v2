defmodule CanvasAPI.TeamService do
  @moduledoc """
  A service for viewing and manipulating teams.
  """

  use CanvasAPI.Web, :service
  alias CanvasAPI.{Account, WhitelistedSlackDomain, Team}
  import CanvasAPI.UUIDMatch

  @preload [:oauth_tokens]

  @doc """
  Insert a team.

  ## Examples

  ```elixir
  TeamService.insert(params, type: :personal)
  ```
  """
  @spec insert(map, Keyword.t) :: {:ok, %Team{}} | {:error, Ecto.Changeset.t}
  def insert(params, type: :personal) do
    %Team{}
    |> Team.create_changeset(params, type: :personal)
    |> Repo.insert
  end

  def insert(params, type: :slack) do
    if domain_whitelisted?(params["domain"]) do
      %Team{}
      |> Team.create_changeset(params, type: :slack)
      |> Repo.insert
    else
      {:error, :domain_not_whitelisted}
    end
  end

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
    from(t in assoc(account, :teams),
         order_by: [desc: is_nil(t.slack_id), asc: :name],
         preload: ^@preload)
    |> filter(opts[:filter])
    |> Repo.all
  end

  @doc """
  Show a specific team by ID or domain.

  Options:

  - `account`: `%Account{}` An account to scope the team find to

  ## Examples

  ```elixir
  TeamService.show("usecanvas")
  ```
  """
  @spec show(String.t, Keyword.t) :: {:ok, %Team{}} | {:error, :not_found}
  def show(id, opts \\ [])

  def show(id, account: account) do
    from(assoc(account, :teams), preload: ^@preload)
    |> do_get(id)
  end

  def show(id, _opts) do
    from(Team, preload: ^@preload)
    |> do_get(id)
  end

  @doc """
  Update a team (currently only allows changing domain of personal teams).

  ## Examples
  ```elixir
  TeamService.update(team, %{"domain" => "my-domain"})
  ```
  """
  @spec update(%Team{}, map) :: {:ok, %Team{}} | {:error, Ecto.Changeset.t}
  def update(team, params) do
    team
    |> Team.update_changeset(params)
    |> Repo.update
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

  @spec domain_whitelisted?(String.t | nil) :: boolean
  defp domain_whitelisted?(nil), do: false
  defp domain_whitelisted?(domain) do
    from(WhitelistedSlackDomain, where: [domain: ^domain])
    |> Repo.one
    |> case do
      nil -> false
      _ -> true
    end
  end

end
