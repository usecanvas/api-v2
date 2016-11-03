defmodule CanvasAPI.TeamTest do
  use CanvasAPI.ModelCase

  alias CanvasAPI.Team
  import CanvasAPI.Factory

  @valid_slack_attrs %{domain: "usecanvas.com", name: "Canvas", slack_id: "FOOBAR"}
  @invalid_slack_attrs %{slack_id: "FOOBAR"}
  @valid_personal_attrs %{}

  describe ".create_changeset/3" do
    test "Slack changeset with valid attributes" do
      changeset =
        Team.create_changeset(%Team{}, @valid_slack_attrs, type: :slack)
      assert changeset.valid?
    end

    test "Slack changeset with invalid attributes" do
      changeset =
        Team.create_changeset(%Team{}, @invalid_slack_attrs, type: :slack)
      refute changeset.valid?
    end

    test "personal changeset with valid attributes" do
      changeset =
        Team.create_changeset(%Team{}, @valid_personal_attrs, type: :personal)
      assert changeset.valid?
    end
  end

  describe ".update_changeset/2" do
    test "prevents Slack domain changes" do
      team = insert(:team)
      changeset = team |> Team.update_changeset(%{"domain" => "foo"})
      assert({:domain, {"can not be changed for Slack teams", []}}
             in changeset.errors)
    end

    test "allows personal domain changes" do
      team = insert(:team, slack_id: nil)
      changeset = team |> Team.update_changeset(%{"domain" => "foo"})
      assert changeset.valid?
      assert Ecto.Changeset.get_change(changeset, :domain) == "~foo"
    end
  end
end
