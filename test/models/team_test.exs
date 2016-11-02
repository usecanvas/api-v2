defmodule CanvasAPI.TeamTest do
  use CanvasAPI.ModelCase

  alias CanvasAPI.Team
  import CanvasAPI.Factory

  @valid_attrs %{domain: "usecanvas.com", name: "Canvas", slack_id: "FOOBAR"}
  @invalid_attrs %{slack_id: "FOOBAR"}

  test "changeset with valid attributes" do
    changeset = Team.changeset(%Team{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Team.changeset(%Team{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "allows changing domain for personal teams" do
    team = insert(:team, slack_id: nil)
    changeset = Team.changeset(team, %{"domain" => "new-domain"})
    assert changeset.valid?
  end

  test "prevents changing domain for Slack teams" do
    team = insert(:team)
    changeset = Team.changeset(team, %{"domain" => "new-domain"})
    assert({:domain, {"can not be changed for Slack teams", []}}
           in changeset.errors)
  end
end
