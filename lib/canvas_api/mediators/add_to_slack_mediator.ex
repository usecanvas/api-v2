defmodule CanvasAPI.AddToSlackMediator do
  @moduledoc """
  Performs the "Add to Slack" OAuth exchange for a team.
  """

  @client_id System.get_env("SLACK_CLIENT_ID")
  @client_secret System.get_env("SLACK_CLIENT_SECRET")
  @redirect_uri System.get_env("ADD_TO_SLACK_REDIRECT_URI")

  alias CanvasAPI.{OAuthToken, Repo, Team}
  import Ecto.Query

  @doc """
  Complete the "Add to Slack" flow by persisting OAuth token and bot info to
  a Slack team.
  """
  @spec add(String.t) :: {:ok, %OAuthToken{}} | {:error, any}
  def add(code) do
    with {:ok, response = %{"ok" => true}} <- exchange_code(code) do
      create_or_update_token(response)
    end
  end

  # Exchange Slack code for Slack information.
  @spec exchange_code(String.t) :: {:ok, map} | {:error, any}
  defp exchange_code(code) do
    Slack.OAuth.access(client_id: @client_id,
                       client_secret: @client_secret,
                       code: code,
                       redirect_uri: @redirect_uri)
  end

  # Persist a slack token.
  @spec create_or_update_token(map) :: {:ok, %OAuthToken{}} | {:error, any}
  defp create_or_update_token(response) do
    with %{ "team_id" => team_id } <- response, 
        team = %Team{} <- find_team(team_id),
         nil <- find_existing_token(team.oauth_tokens) do
      create_token(team, response)
    else
      token = %OAuthToken{} ->
        update_token(token, response)
      error ->
        error
    end
  end

  @spec create_token(%Team{}, map) :: {:ok, %OAuthToken{}} | {:error, any}
  defp create_token(team, %{ "bot" => bot, "scope" => scopes, 
    "access_token" => token }) do
    %OAuthToken{}
    |> OAuthToken.changeset(
         %{meta: %{"bot" => bot, "scopes" => format_scope(scopes)},
           provider: "slack",
           token: token})
    |> Ecto.Changeset.put_assoc(:team, team)
    |> Repo.insert
  end

  @spec update_token(%OAuthToken{}, map) :: {:ok, %OAuthToken{}} | {:error, any}
  defp update_token(token, %{ "scope" => scopes }) do
    token
    |> OAuthToken.changeset(
         %{meta: Map.put(token.meta, "scopes", format_scope(scopes)) })
    |> Repo.update
  end

  # Find an existing OAuth token.
  @spec find_existing_token([%OAuthToken{}] | []) :: %OAuthToken{} | nil
  defp find_existing_token(tokens) do
    Enum.find(tokens, &(&1.provider == "slack"))
  end

  @spec format_scope(String.t) :: [String.t]
  defp format_scope(scope), do: String.split(scope, ",")

  # Find a team by slack ID.
  @spec find_team(String.t) :: %Team{} | nil
  defp find_team(slack_id) do
    from(Team, where: [slack_id: ^slack_id], preload: [:oauth_tokens])
    |> Repo.one
  end
end
