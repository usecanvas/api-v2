defmodule CanvasAPI.TeamControllerTest do
  use CanvasAPI.ConnCase

  alias CanvasAPI.{Account, Repo, Team}
  import CanvasAPI.Factory

  @valid_attrs %{}
  @invalid_attrs %{}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe ".index/2" do
    test "lists all entries on index", %{conn: conn} do
      account = Repo.insert! %Account{}

      conn =
        conn
        |> put_private(:current_account, account)
        |> get(team_path(conn, :index))

      assert json_response(conn, 200)["data"] == []
    end
  end

  describe ".update/2" do
    test "updates the personal team name", %{conn: conn} do
      team = insert(:team, name: "", domain: "", slack_id: nil)
      %{account: account, team: team} = insert(:user, team: team)

      conn =
        conn
        |> put_private(:current_account, account)
        |> patch(team_path(conn, :update, team), %{
             "data" => %{
               "attributes" => %{"domain" => "foo-domain"}
             }
           })

      assert Repo.reload(team).domain == "~foo-domain"
    end
  end
end
