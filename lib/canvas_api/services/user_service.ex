defmodule CanvasAPI.UserService do
  @moduledoc """
  A service for viewing and manipulating users.
  """

  use CanvasAPI.Web, :service
  alias CanvasAPI.User

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
  def insert(params, opts) do
    %User{}
    |> User.changeset(params)
    |> put_assoc(:account, opts[:account])
    |> put_assoc(:team, opts[:team])
    |> Repo.insert
  end
end
