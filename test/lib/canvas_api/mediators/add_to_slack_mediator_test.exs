defmodule CanvasAPI.AddToSlackMediatorTest do
  use CanvasAPI.ModelCase

  alias CanvasAPI.AddToSlackMediator, as: Mediator

  import Mock
  import CanvasAPI.Factory

  setup do
    {:ok, team: insert(:team)}
  end

  describe ".add" do
    test "persists a new OAuth token for the team", %{team: team} do
      with_mock Slack.OAuth, [access: mock_access(team)] do
        {:ok, token} = Mediator.add("code")
        assert token.team_id == team.id
        assert(
          get_in(token.meta, ~w(bot bot_access_token)) == "bot_access_token")
      end
    end

    test "returns an existing OAuth token for the team", %{team: team} do
      token = insert(:oauth_token, team: team, provider: "slack")

      with_mock Slack.OAuth, [access: mock_access(team)] do
        {:ok, found_token} = Mediator.add("code")
        assert found_token.id == token.id
      end
    end

    test "returns a changeset for an invalid token", %{team: team} do
      with_mock Slack.OAuth, [access: mock_access(team, nil)] do
        {:error, changeset} = Mediator.add("code")
        assert {:token, {"can't be blank", []}} in changeset.errors
      end
    end
  end

  defp mock_access(team, access_token \\ "access_token") do
    fn client_id: _, client_secret: _, code: _, redirect_uri: _ ->
      {:ok,
       %{"access_token" => access_token,
         "bot" => %{"bot_access_token" => "bot_access_token"},
         "team_id" => team.slack_id}}
    end
  end
end
