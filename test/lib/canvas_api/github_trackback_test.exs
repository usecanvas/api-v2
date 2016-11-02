defmodule CanvasAPI.GitHubTrackbackTest do
  use CanvasAPI.ModelCase

  alias CanvasAPI.{Canvas, GitHubTrackback, PulseEvent,Referencer, Repo}
  import CanvasAPI.Factory

  setup do
    {:ok, canvas: insert(:canvas)}
  end

  test ".add adds an event for a created comment", %{canvas: canvas} do
    comment = github_event(canvas)

    {:ok, event} =
      GitHubTrackback.add(%{"action" => "created", "comment" => comment})

    assert event.url == comment["html_url"]
    assert event.type == "reference_added"

    assert event.referencer == %Referencer{
      id: get_in(comment, ~w(user id)),
      avatar_url: get_in(comment, ~w(user avatar_url)),
      name: "@#{get_in(comment, ~w(user login))}",
      url: get_in(comment, ~w(user html_url))
    }

    assert event.canvas.id == canvas.id
  end

  test ".add adds an event for a submitted review", %{canvas: canvas} do
    review = github_event(canvas)

    {:ok, event} =
      GitHubTrackback.add(%{"action" => "submitted", "review" => review})

    assert event.url == review["html_url"]
    assert event.type == "reference_added"

    assert event.referencer == %Referencer{
      id: get_in(review, ~w(user id)),
      avatar_url: get_in(review, ~w(user avatar_url)),
      name: "@#{get_in(review, ~w(user login))}",
      url: get_in(review, ~w(user html_url))
    }

    assert event.canvas.id == canvas.id
  end

  test ".add adds an event for an opened issue", %{canvas: canvas} do
    issue = github_event(canvas) |> Map.merge(%{
      "title" => Canvas.web_url(canvas),
      "body" => "",
    })

    {:ok, event} =
      GitHubTrackback.add(%{"action" => "opened", "issue" => issue})

    assert event.url == issue["html_url"]
    assert event.type == "reference_added"

    assert event.referencer == %Referencer{
      id: get_in(issue, ~w(user id)),
      avatar_url: get_in(issue, ~w(user avatar_url)),
      name: "@#{get_in(issue, ~w(user login))}",
      url: get_in(issue, ~w(user html_url))
    }

    assert event.canvas.id == canvas.id
  end

  test ".add adds an event for an opened pull request", %{canvas: canvas} do
    pr = github_event(canvas) |> Map.merge(%{
      "title" => Canvas.web_url(canvas),
      "body" => "",
    })

    {:ok, event} =
      GitHubTrackback.add(%{"action" => "opened", "pull_request" => pr})

    assert event.url == pr["html_url"]
    assert event.type == "reference_added"

    assert event.referencer == %Referencer{
      id: get_in(pr, ~w(user id)),
      avatar_url: get_in(pr, ~w(user avatar_url)),
      name: "@#{get_in(pr, ~w(user login))}",
      url: get_in(pr, ~w(user html_url))
    }

    assert event.canvas.id == canvas.id
  end

  test ".add adds events for commits", %{canvas: canvas} do
    commits = [
      %{
        "message" => "Foo"
      },
      %{
        "message" => Canvas.web_url(canvas),
        "url" => "commit-url",
        "author" => %{
          "email" => "auth-email",
          "name" => "auth-name"
        }
      },
      %{
        "message" => Canvas.web_url(canvas),
        "url" => "commit-url",
        "author" => %{
          "email" => "auth-email",
          "name" => "auth-name"
        }
      }
    ]

    :ok = GitHubTrackback.add(%{"commits" => commits})
    events = Repo.all(PulseEvent)
    assert Enum.map(events, & &1.type) |> Enum.dedup == ["mentioned"]
    assert Enum.map(events, & &1.url) |> Enum.dedup == ["commit-url"]
    assert Enum.map(events, & &1.referencer.id) |> Enum.dedup == ["auth-email"]
  end

  defp github_event(canvas) do
    %{
      "body" => Canvas.web_url(canvas),
      "html_url" => "comment-url",
      "user" => %{
        "id" => "user-id",
        "avatar_url" => "user-avatar_url",
        "login" => "user-login",
        "html_url" => "user-html_url"
      }
    }
  end
end
