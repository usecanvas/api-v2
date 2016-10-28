defmodule CanvasAPI.TeamService do
  @moduledoc """
  A service for viewing and manipulating teams.
  """

  use CanvasAPI.Web, :service
  alias CanvasAPI.{Account, Team}
  import CanvasAPI.UUIDMatch

  @preload [:oauth_tokens]

  @spec list(%Account{}, Keyword.t) :: [%Team{}]
  def list(account, opts) do
    from(assoc(account, :teams),
         order_by: [:name],
         preload: ^@preload)
    |> filter(opts[:filter])
    |> Repo.all
  end

  @spec show(String.t) :: %Team{} | nil
  def show(id) do
    from(Team, preload: ^@preload)
    |> do_get(id)
  end

  @spec do_get(Ecto.Queryable.t, String.t) :: %Team{} | nil
  defp do_get(queryable, id = match_uuid()), do: Repo.get(queryable, id)
  defp do_get(queryable, domain) do
    queryable
    |> where(domain: ^domain)
    |> Repo.one
  end

  @spec add_account_user(%Team{}, %Account{} | nil) :: %Team{}
  def add_account_user(team, nil), do: team
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
