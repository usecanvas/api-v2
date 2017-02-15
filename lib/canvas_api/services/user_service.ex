defmodule CanvasAPI.UserService do
  @moduledoc """
  A service for viewing and manipulating users.
  """

  use CanvasAPI.Web, :service
  alias CanvasAPI.{Account, Team, User}

  @preload [:team]

  @doc """
  Insert a new user from the given params.

  The creator must provide an account and a team.

  Options:

  - `account`: `%Account{}` (**required**) The account the user will be tied to
  - `team`: `%Team{}` (**required**) The team the user will be tied to

  ## Examples

  ```elixir
  UserService.create(
    %{"email" => "user@example.com"},
    account: current_account,
    team: current_team)
  ```
  """
  @spec insert(params::map, options::Keyword.t) :: User.t
                                                 | {:error, Ecto.Changeset.t}
  def insert(params, opts) do
    %User{}
    |> User.changeset(params)
    |> put_assoc(:account, opts[:account])
    |> put_assoc(:team, opts[:team])
    |> Repo.insert
  end

  @doc """
  Find a user for a given account and team ID.


  ## Examples

  ```elixir
  UserService.find_by_team(
    account, team_id: team.id)
  ```
  """
  @spec find_by_team(Account.t, Keyword.t) :: {:ok, User.t}
                                            | {:error, :not_found}
  def find_by_team(account, team_domain: team_domain) do
    from(u in assoc(account, :users),
         join: t in Team, on: t.id == u.team_id,
         where: t.domain == ^team_domain,
         preload: [:team])
    |> Repo.one
    |> case do
      nil ->  {:error, :not_found}
      user -> {:ok, user}
    end
  end

  def find_by_team(account, team_id: team_id) do
    from(u in assoc(account, :users),
         join: t in Team, on: t.id == u.team_id,
         where: t.id == ^team_id,
         preload: [:team])
    |> Repo.one
    |> case do
      nil ->  {:error, :not_found}
      user -> {:ok, user}
    end
  end

  @doc """
  Get a user by ID.
  """
  @spec get(String.t) :: {:ok, User.t} | {:error, :not_found}
  def get(user_id) do
    User
    |> Repo.get(user_id)
    |> case do
      nil ->
        {:error, :not_found}
      user ->
        {:ok, Repo.preload(user, @preload)}
    end
  end

end
