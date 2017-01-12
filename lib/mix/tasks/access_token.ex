defmodule Mix.Tasks.CanvasApi.AccessToken do
  @moduledoc """
  Generate a personal access token for an account.

  A personal access token is tied to an account, but must be created either by

  1. Providing a personal domain (e.g. "~clem")
  2. Providing a Slack team domain and a user email

  This is because an email may be tied to multiple accounts (e.g. different
  teams that aren't tied together under one account).

  ## Examples

  ### For a Slack team user account:

      mix canvas_api.access_token usecanvas user@example.com

  ### For a personal domain user account:

      mix canvas_api.access_token "~clem"
  """

  @shortdoc "Generate a personal access token"

  require Logger

  use Mix.Task
  import Ecto.Query
  import Ecto.Changeset, only: [put_assoc: 3]
  alias CanvasAPI.{PersonalAccessToken, Repo, User}

  def run([domain = "~" <> _]) do
    Mix.Task.run("app.start", [])

    domain
    |> get_account_from_personal_domain()
    |> do_run()
  end

  def run ([domain]) do
    Logger.error """
    "#{domain}" is not a valid personal domain. It must begin with a tilde (~).
    """
    exit({:shutdown, 1})
  end

  def run([domain, email]) do
    Mix.Task.run("app.start", [])

    domain
    |> get_account(email)
    |> do_run()
  end

  defp do_run(nil) do
    Logger.error "No such account found."
    exit({:shutdown, 1})
  end

  defp do_run(account), do: account |> Map.get(:account) |> generate_token()

  defp generate_token(account) do
    %PersonalAccessToken{}
    |> PersonalAccessToken.changeset()
    |> put_assoc(:account, account)
    |> Repo.insert!()
    |> format()
    |> IO.puts()
  end

  defp get_account_from_personal_domain(domain) do
    domain
    |> base_query()
    |> Repo.one()
  end

  defp get_account(domain, email) do
    domain
    |> base_query()
    |> where([u], u.email == ^email)
    |> Repo.one()
  end

  defp base_query(domain) do
    User
    |> join(:left, [u], _ in assoc(u, :account))
    |> join(:left, [u], _ in assoc(u, :team))
    |> where([..., t], t.domain == ^domain)
    |> preload([u, a], [account: a])
  end

  defp format(token) do
    "#{Base62UUID.encode(token.id)}:#{token.token}"
  end
end
