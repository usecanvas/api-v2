defmodule CanvasAPI.Factory do
  use ExMachina.Ecto, repo: CanvasAPI.Repo

  def account_factory do
    %CanvasAPI.Account{}
  end

  def team_factory do
    %CanvasAPI.Team{
      domain: "usecanvas",
      images: %{},
      name: "Canvas",
      slack_id: sequence(:slack_id, &"ABCDEFG#{&1}")
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
