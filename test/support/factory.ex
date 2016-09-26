defmodule CanvasAPI.Factory do
  use ExMachina.Ecto, repo: CanvasAPI.Repo

  def account_factory do
    %CanvasAPI.Account{}
  end

  def canvas_factory do
    user = insert(:user)

    %CanvasAPI.Canvas{
      id: sequence(:id, fn _ -> Base62UUID.generate end),
      creator: user,
      team: user.team
    }
  end

  def team_factory do
    %CanvasAPI.Team{
      domain: sequence(:domain, &"domain-#{&1}"),
      images: %{},
      name: "Canvas",
      slack_id: sequence(:slack_id, &"ABCDEFG#{&1}")
    }
  end

  def whitelisted_domain_factory do
    %CanvasAPI.WhitelistedSlackDomain{
      domain: sequence(:domain, &"domain-#{&1}")
    }
  end

  def user_factory do
    %CanvasAPI.User{
      email: "user@example.com",
      identity_token: "abc",
      images: %{},
      name: "Hal Holbrook",
      slack_id: sequence(:slack_id, &"ABCDEFG#{&1}"),
      account: build(:account),
      team: build(:team)
    }
  end
end
