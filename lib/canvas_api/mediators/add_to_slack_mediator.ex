defmodule CanvasAPI.AddToSlackMediator do
  @moduledoc """
  Performs the "Add to Slack" OAuth exchange for a team.
  """

  @client_id System.get_env("SLACK_CLIENT_ID")
  @client_secret System.get_env("SLACK_CLIENT_SECRET")
  @redirect_uri System.get_env("ADD_TO_SLACK_REDIRECT_URI")

  alias CanvasAPI.{OAuthToken, Repo, Team}
  import Ecto.Query

  def add(code) do
    with {:ok, %{"access_token" => token, "bot" => bot, "team_id" => team_id}}
      <- exchange_code(code) do
      persist_token(token, bot, team_id)
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
  @spec persist_token(String.t, map, String.t) :: {:ok, %OAuthToken{}} | {:error, any}
  defp persist_token(token, bot, team_id) do
    with team = %Team{} <- find_team(team_id),
         nil <- find_existing_token(team.oauth_tokens) do
      %OAuthToken{}
      |> OAuthToken.changeset(
        %{meta: %{"bot" => bot}, provider: "slack", token: token})
      |> Ecto.Changeset.put_assoc(:team, team)
      |> Repo.insert
    else
      token = %OAuthToken{} ->
        {:ok, token}
      error ->
        error
    end
  end

  # Find an existing OAuth token.
  @spec find_existing_token([%OAuthToken{}] | []) :: %OAuthToken{} | nil
  defp find_existing_token(tokens) do
    Enum.find(tokens, &(&1.provider == "slack"))
  end

  # Find a team by slack ID.
  @spec find_team(String.t) :: %Team{} | nil
  defp find_team(slack_id) do
    from(Team, where: [slack_id: ^slack_id], preload: [:oauth_tokens])
    |> Repo.one
  end
end
