defmodule Mix.Tasks.CanvasApi.AccessToken do
  @moduledoc """
  Generate a personal access token for an account.

  Accepts an email address tied to a Slack user.

  ## Examples

      mix canvas_api.access_token usecanvas user@example.com
  """

  @shortdoc "Generate a personal access token"

  use Mix.Task
  import Ecto.Query, only: [from: 2]
  import Ecto.Changeset, only: [put_assoc: 3]
  alias CanvasAPI.{PersonalAccessToken, Repo, Team, User}

  def run([domain = "~" <> _]) do
    Mix.Task.run("app.start", [])
    get_account_from_personal_domain(domain)
    |> generate_token
  end

  def run([domain, email]) do
    Mix.Task.run("app.start", [])
    get_account(domain, email)
    |> generate_token
  end

  defp generate_token(account) do
    %PersonalAccessToken{}
    |> PersonalAccessToken.changeset
    |> put_assoc(:account, account)
    |> Repo.insert!
    |> format
    |> IO.puts
  end

  defp get_account_from_personal_domain(domain) do
    from(u in User,
         join: t in Team, on: t.id == u.team_id,
         where: t.domain == ^domain,
         preload: [:account])
    |> Repo.one!
    |> Map.get(:account)
  end

  defp get_account(domain, email) do
    from(u in User,
         join: t in Team, on: t.id == u.team_id,
         where: t.domain == ^domain,
         where: u.email == ^email, preload: [:account])
    |> Repo.one!
    |> Map.get(:account)
  end

  defp format(token) do
    "#{Base62UUID.encode(token.id)}:#{token.token}"
  end
end
