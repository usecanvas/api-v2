defmodule CanvasAPI.SignInMediatorTest do
  use CanvasAPI.ModelCase

  alias CanvasAPI.SignInMediator, as: Mediator

  import Mock
  import CanvasAPI.Factory

  @mock_team %{
    "id" => "team_id",
    "domain" => "test-team",
    "name" => "Test Team",
    "image_254" => "https://example.com/team-image.png"
  }

  @mock_user %{
    "id" => "user_id",
    "email" => "user@example.com",
    "name" => "User Name",
    "image_88" => "https://example.com/user-image.png"
  }

  setup do
    insert(:whitelisted_domain, domain: @mock_team["domain"])
    :ok
  end

  test "creates a new account, personal team, team, and user" do
    with_mock Slack.OAuth, [access: mock_access] do
      account =
        Mediator.sign_in("ABCDEFG", account: nil)
        |> elem(1)
        |> Repo.preload([:teams, :users])

      [team, personal_team] = account.teams
      [user, personal_user] = Repo.preload(account.users, [:team])

      assert personal_team.name == "Notes"
      assert personal_team.domain == nil
      assert personal_user.email == "account-#{account.id}@usecanvas.com"
      assert personal_user.name == "Canvas User"
      assert team.name == "Test Team"
      assert user.identity_token == "access_token"
      assert user.team == team
    end
  end

  test "attaches team and user to existing account" do
    account = insert(:account)

    with_mock Slack.OAuth, [access: mock_access] do
      {:ok, linked_account} = Mediator.sign_in("ABCDEFG", account: account)
      assert linked_account.id == account.id
    end
  end

  test "allows only one user per team per account" do
    account = insert(:account)

    with_mock Slack.OAuth, [access: mock_access] do
      {:ok, _} = Mediator.sign_in("ABCDEFG", account: account)
    end

    user = %{"id" => "user_2_id", "email" => "email", "name" => "Name"}

    with_mock Slack.OAuth, [access: mock_access(user: user)] do
      {:error, changeset} = Mediator.sign_in("ABCDEFG", account: account)
      assert(
        {:team_id, {"already exists for this account", []}} in changeset.errors)
    end
  end

  test "allows only whitelisted teams" do
    mock_team = @mock_team |> Map.merge(%{"domain" => "un-whitelist"})

    with_mock Slack.OAuth, [access: mock_access(team: mock_team)] do
      {:error, error} = Mediator.sign_in("ABCDEFG", account: nil)
      assert error == {:domain_not_whitelisted, mock_team["domain"]}
    end
  end

  defp mock_access(opts \\ []) do
    team = opts[:team] || @mock_team
    user = opts[:user] || @mock_user

    fn (client_id: _, client_secret: _, code: _, redirect_uri: _) ->
      {:ok,
        %{
          "access_token" => "access_token",
          "team" => team,
          "user" => user
        }
      }
    end
  end
end
