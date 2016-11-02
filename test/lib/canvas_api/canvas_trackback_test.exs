defmodule CanvasAPI.CanvasTrackbackTest do
  use CanvasAPI.ModelCase

  alias CanvasAPI.{AvatarURL, CanvasTrackback, Referencer}
  import CanvasAPI.Factory
  import Mock

  setup do
    user = insert(:user)
    target = insert(:canvas, team: user.team)
    source = insert(:canvas, team: user.team)
    {:ok, user: user, target: target, source: source}
  end

  test ".add creates an event for the target from the source", context do
    event = CanvasTrackback.add(context.target.id,
                                context.source.id,
                                context.user.account.id)

    assert event.type == "reference_added"

    assert event.referencer == %Referencer{
        id: context.user.id,
        avatar_url: AvatarURL.create(context.user.email),
        email: context.user.email,
        name: context.user.name,
        url: "mailto:#{context.user.email}"
    }

    assert event.canvas.id == context.target.id
  end

  test ".remove creates an event from the target from the source", context do
    event = CanvasTrackback.remove(context.target.id,
                                   context.source.id,
                                   context.user.account.id)

    assert event.type == "reference_removed"

    assert event.referencer == %Referencer{
        id: context.user.id,
        avatar_url: AvatarURL.create(context.user.email),
        email: context.user.email,
        name: context.user.name,
        url: "mailto:#{context.user.email}"
    }

    assert event.canvas.id == context.target.id
  end

  describe ".Worker" do
    test "adds a reference" do
      with_mock CanvasTrackback, [add: fn(_, _, _) -> nil end] do
        CanvasTrackback.Worker.perform("add", "a", "b", "c")
        assert called CanvasTrackback.add("a", "b", "c")
      end
    end

    test "removes a reference" do
      with_mock CanvasTrackback, [remove: fn(_, _, _) -> nil end] do
        CanvasTrackback.Worker.perform("remove", "a", "b", "c")
        assert called CanvasTrackback.remove("a", "b", "c")
      end
    end
  end
end
