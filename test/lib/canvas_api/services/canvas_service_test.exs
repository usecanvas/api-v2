defmodule CanvasAPI.CanvasServiceTest do
  use CanvasAPI.ModelCase

  alias CanvasAPI.{Block, Canvas, CanvasService}
  import CanvasAPI.Factory
  import Mock

  setup do
    {:ok, user: insert(:user)}
  end

  describe ".create" do
    test "creates a canvas with the given creator and team", %{user: user} do
      {:ok, canvas} =
        %{"slack_channel_ids" => ["abcdef"], "link_access" => "edit"}
        |> CanvasService.create(
          creator: user,
          team: user.team)

      assert canvas.creator == user
      assert canvas.team == user.team
      assert canvas.slack_channel_ids == ["abcdef"]
    end

    test "creates a canvas from a template", %{user: user} do
      block = %{
        type: "title",
        content: "Template Title",
        meta: %{"placeholder" => "Placeholder"}}

      template = insert(:canvas, blocks: [block])

      {:ok, canvas} =
        %{"slack_channel_ids" => ["abcdef"]}
        |> CanvasService.create(
          creator: user,
          team: user.team,
          template: %{"id" => template.id, "type" => "canvas"})

      assert canvas.template_id == template.id
      assert Enum.map(canvas.blocks, & &1.content) == ["Template Title"]
    end

    test "sends a notification when instructed", %{user: user} do
      with_mock(
        CanvasAPI.SlackChannelNotifier, [delay_notify_new: &mock_notify/5]) do
          token = insert(:oauth_token, team: user.team, provider: "slack")

          {:ok, canvas} =
            %{"slack_channel_ids" => ["abcdef"]}
            |> CanvasService.create(
              creator: user,
              team: user.team,
              notify: user)

          assert called CanvasAPI.SlackChannelNotifier.delay_notify_new(
            get_in(token.meta, ~w(bot bot_access_token)),
            canvas.id,
            user.id,
            "abcdef",
            delay: 300)
        end
    end

    defp mock_notify(_token, _canvas, _notifier_id, _channel_id, _opts), do: nil
  end

  describe ".list" do
    test "lists all canvases for a user", %{user: user} do
      team_canvas = insert(:canvas, team: user.team)
      template_canvas = insert(:canvas, team: user.team, is_template: true)
      insert(:canvas)

      assert Enum.map(CanvasService.list(user: user), & &1.id) ==
        [team_canvas.id, template_canvas.id]
    end

    test "lists template canvases for a user", %{user: user} do
      template_canvas = insert(:canvas, team: user.team, is_template: true)
      insert(:canvas, team: user.team)
      insert(:canvas)

      ids =
        CanvasService.list(user: user, only_templates: true)
        |> Enum.map(& &1.id)
      assert ids == [template_canvas.id]
    end

    test "includes global templates", %{user: user} do
      template_user = insert(:user)
      System.put_env("TEMPLATE_USER_ID", template_user.id)
      global_template_canvas =
        insert(:canvas,
               creator: template_user,
               team: template_user.team,
               is_template: true)

      ids =
        CanvasService.list(user: user, only_templates: true)
        |> Enum.map(& &1.id)
      assert ids == [global_template_canvas.id]
    end
  end

  describe ".get" do
    test "finds a canvas amongst an account's accessible canvases" do
      canvas = Repo.preload(insert(:canvas), [:template])
      assert CanvasService.get(canvas.id,
                               account: canvas.creator.account,
                               team_id: canvas.team_id) ==
      {:ok,
       Repo.preload(Repo.get(Canvas, canvas.id),
                    [:team, :template, creator: [:team]])}
    end

    test "returns a not found error if no canvas is found" do
      canvas = insert(:canvas)
      assert CanvasService.get(canvas.id,
                               account: insert(:account),
                               team_id: canvas.team_id) == {:error, :not_found}
    end
  end

  describe ".show" do
    setup do
      {:ok, canvas: Repo.preload(insert(:canvas), [:template])}
    end

    test "finds a canvas with an ID in a given team by team ID", context do
      canvas = context.canvas
      assert CanvasService.show(canvas.id,
                                account: canvas.creator.account,
                                team_id: canvas.team_id) ==
      {:ok,
       Repo.preload(Repo.get(Canvas, canvas.id),
                    [:team, :template, creator: [:team]])}
    end

    test "finds a canvas with an ID in a given team by team domain", context do
      canvas = context.canvas
      assert CanvasService.show(canvas.id,
                                account: canvas.creator.account,
                                team_id: canvas.team.domain) ==
      {:ok,
       Repo.preload(Repo.get(Canvas, canvas.id),
                    [:team, :template, creator: [:team]])}
    end
  end

  describe ".update" do
    setup context do
      canvas =
        insert(:canvas,
               blocks: [%Block{type: "title", content: "Title"}],
               creator: context[:user],
               team: context[:user].team)
      {:ok, canvas: canvas |> Repo.preload([:template])}
    end

    test "updates a canvas", %{canvas: canvas} do
      {:ok, updated_canvas} =
        canvas
        |> CanvasService.update(%{"slack_channel_ids" => ["abc"]})

      assert updated_canvas.id === canvas.id
      assert updated_canvas.slack_channel_ids == ["abc"]
    end

    test "updates the canvas template", %{canvas: canvas} do
      template =
        insert(:canvas, is_template: true, team: canvas.team, blocks: [])
      template_rel_object = %{"type" => "canvas", "id" => template.id}

      {:ok, updated_canvas} =
        canvas
        |> CanvasService.update(%{}, template: template_rel_object)

      assert updated_canvas.template_id == template.id
      assert updated_canvas.blocks == canvas.blocks
    end

    test "sends notifications when specified", %{canvas: canvas, user: user} do
      with_mock(
        CanvasAPI.SlackChannelNotifier, [delay_notify_new: &mock_notify/5]) do
          token = insert(:oauth_token, team: user.team, provider: "slack")

          {:ok, _} =
            canvas
            |> CanvasService.update(%{"slack_channel_ids" => ["abc"]},
              notify: user)

          assert called CanvasAPI.SlackChannelNotifier.delay_notify_new(
            get_in(token.meta, ~w(bot bot_access_token)),
            canvas.id,
            user.id,
            "abc",
            [])
        end
    end
  end

  describe ".delete" do
    test "deletes a canvas" do
      canvas = insert(:canvas)
      account = canvas.creator.account

      {:ok, canvas} =
        CanvasService.delete(
          canvas.id, account: account, team_id: canvas.team_id)
      assert Repo.get(Canvas, canvas.id) == nil
    end

    test "returns not_found for a not found canvas" do
      canvas = insert(:canvas)
      account = canvas.creator.account
      CanvasService.delete(canvas.id, account: account, team_id: canvas.team_id)
      assert CanvasService.delete(
        canvas.id, account: account, team_id: canvas.team_id) ==
          {:error, :not_found}
    end
  end
end
