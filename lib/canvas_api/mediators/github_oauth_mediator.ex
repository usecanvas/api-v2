defmodule CanvasAPI.GitHubOAuthMediator do
  @moduledoc """
  Handle a GitHub OAuth by persisting an authorization token.
  """

  alias CanvasAPI.{Account, OAuthToken, Repo}
  alias CanvasAPI.Unfurl.GitHub.API, as: GitHubAPI

  @client_id System.get_env("GITHUB_CLIENT_ID")
  @client_secret System.get_env("GITHUB_CLIENT_SECRET")

  @spec persist_token(String.t, Keyword.t) :: :ok | {:error, any}
  def persist_token(code, account: account) do
    with {:ok, access_token} <- exchange_code(code) do
      persist_oauth_token(access_token, account)
    end
  end

  @spec exchange_code(String.t) ::
        {:ok, String.t} | {:error, any}
  defp exchange_code(code) do
    GitHubAPI.post("https://github.com/login/oauth/access_token",
      "",
      [{"accept", "application/json"}],
      params: [{"client_id", @client_id},
               {"client_secret", @client_secret},
               {"code", code}])
   |> case do
     {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
       {:ok, body["access_token"]}
     {:ok, %HTTPoison.Response{status_code: status_code}} ->
       {:error, "Expected 200 from GitHub, got #{status_code}"}
     {:error, error} ->
       {:error, error}
   end
  end

  @spec persist_oauth_token(String.t, %Account{}) ::
        {:ok, %OAuthToken{}} | {:error, any}
  defp persist_oauth_token(access_token, account) do
    changeset =
      %OAuthToken{}
      |> OAuthToken.changeset(%{provider: "github", token: access_token})
      |> Ecto.Changeset.put_assoc(:account, account)
    Repo.insert(changeset)
  end
end
