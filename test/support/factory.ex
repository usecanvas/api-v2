defmodule CanvasAPI.Factory do
  use ExMachina.Ecto, repo: CanvasAPI.Repo

  alias CanvasAPI.Block

  def account_factory do
    %CanvasAPI.Account{}
  end

  def block_factory do
    %Block{
      id: Base62UUID.generate,
      type: "paragraph",
      content: ""}
  end

  def heading_block_factory do
    %Block{
      id: Base62UUID.generate,
      type: "heading",
      content: "",
      meta: %{"level" => 1}}
  end

  def title_block_factory do
    %Block{
      id: Base62UUID.generate,
      type: "title",
      content: ""}
  end

  def list_block_factory do
    %Block{
      id: Base62UUID.generate,
      type: "list",
      blocks: []}
  end

  def cl_block_factory do
    %Block{
      id: Base62UUID.generate,
      type: "checklist-item",
      content: "",
      meta: %{"checked" => false}}
  end

  def ul_block_factory do
    %Block{
      id: Base62UUID.generate,
      type: "unordered-list-item",
      content: ""}
  end

  def canvas_factory do
    user = insert(:user)

    %CanvasAPI.Canvas{
      id: sequence(:id, fn _ -> Base62UUID.generate end),
      blocks: [%CanvasAPI.Block{type: "title", content: "Title"}],
      creator: user,
      team: user.team
    }
  end

  def comment_factory do
    canvas = insert(:canvas)

    %CanvasAPI.Comment{
      blocks: [build(:block)],
      block_id: Base62UUID.generate,
      canvas: canvas,
      creator: canvas.creator
    }
  end

  def oauth_token_factory do
    %CanvasAPI.OAuthToken{
      token: "token",
      account: build(:account),
      team: build(:team),
      provider: "provider",
      meta: %{"bot" => %{"bot_access_token" => "bot_access_token"}}
    }
  end

  def op_factory do
    %CanvasAPI.Op{
      canvas: build(:canvas),
      components: [],
      meta: %{},
      seq: 0,
      source: "source",
      version: sequence(:version, &(&1))
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

  def thread_subscription_factory do
    canvas = insert(:canvas)

    %CanvasAPI.ThreadSubscription{
      subscribed: false,
      user: build(:user, team: canvas.team),
      canvas: canvas,
      block_id: List.first(canvas.blocks).id
    }
  end

  def ui_dismissal_factory do
    %CanvasAPI.UIDismissal{
      account: build(:account),
      identifier: sequence(:identifier, &"#{&1}")
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

  def canvas_watch_factory do
    canvas = insert(:canvas)

    %CanvasAPI.CanvasWatch{
      canvas: canvas,
      user: build(:user, team: canvas.team)
    }
  end

  def whitelisted_domain_factory do
    %CanvasAPI.WhitelistedSlackDomain{
      domain: sequence(:domain, &"domain-#{&1}")
    }
  end
end
