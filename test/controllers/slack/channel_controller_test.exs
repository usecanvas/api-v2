defmodule CanvasAPI.Slack.ChannelControllerTest do
  use CanvasAPI.ConnCase

  import CanvasAPI.Factory
  import Mock

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json"),
          user: insert(:user)}
  end

  describe "GET .index/2" do
    test "renders channels when successful", %{conn: conn, user: user} do
      with_mock Slack.Channel, [list: &mock_list/2] do
        conn =
          conn
          |> put_private(:current_account, user.account)
          |> get(team_channel_path(conn, :index, user.team))

        assert(
          json_response(conn, 200)["data"]
          |> Enum.at(0)
          |> get_in(~w(attributes name)) === "Name")
      end
    end

    test "renders 400 when token revoked", %{conn: conn, user: user} do
      with_mock Slack.Channel, [list: &mock_list_revoked/2] do
        conn =
          conn
          |> put_private(:current_account, user.account)
          |> get(team_channel_path(conn, :index, user.team))

        assert json_response(conn, 400) ==
          %{"errors" => %{"detail" => "Slack token revoked"}}
      end
    end

    test "renders 400 when request fails", %{conn: conn, user: user} do
      with_mock Slack.Channel, [list: &mock_list_fail/2] do
        conn =
          conn
          |> put_private(:current_account, user.account)
          |> get(team_channel_path(conn, :index, user.team))

        assert json_response(conn, 400)
      end
    end
  end

  defp mock_list(_client, exclude_archived: 1) do
    {:ok,
     %{"channels" => [%{"name" => "Name", "topic" => %{"value" => "topic"}}]}}
  end

  defp mock_list_revoked(_client, exclude_archived: 1) do
    {:error,
     %HTTPoison.Response{body: %{"error" => "token_revoked"}}}
  end

  defp mock_list_fail(_client, exclude_archived: 1) do
    {:error,
     %HTTPoison.Response{body: %{"error" => "error"}}}
  end
end
