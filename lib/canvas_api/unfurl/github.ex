defmodule CanvasAPI.Unfurl.GitHub do
  alias CanvasAPI.{Account, OAuthToken, Repo, User}

  import Ecto.Query, only: [from: 2]

  def unfurl(block) do
    with mod when is_atom(mod) <- get_unfurl_mod(block),
         unfurl when not is_nil(unfurl) <- mod.unfurl(block) do
      %CanvasAPI.Unfurl{
        unfurl |
          provider_name: "GitHub",
          provider_url: "https://github.com",
          provider_icon_url: "https://s3.amazonaws.com/canvas-assets/provider-icons/github.png"
      }
    end
  end

  def get_token_for_block(block) do
    from(t in OAuthToken,
         join: a in Account, on: a.id == t.account_id,
         join: u in User, on: u.account_id == a.id,
         where: u.id == ^block.meta["creator_id"],
         where: t.provider == ^"github")
     |> Repo.one
  end

  defp get_unfurl_mod(block) do
    url = block.meta["url"]

    cond do
      is_repo?(url) -> CanvasAPI.Unfurl.GitHub.Repo
      is_issue?(url) -> CanvasAPI.Unfurl.GitHub.Issue
      is_pull_request?(url) -> CanvasAPI.Unfurl.GitHub.PullRequest
      true -> CanvasAPI.Unfurl.OpenGraph
    end
  end

  defp is_repo?(url) do
    Regex.match?(CanvasAPI.Unfurl.GitHub.Repo.match, url)
  end

  defp is_issue?(url) do
    Regex.match?(CanvasAPI.Unfurl.GitHub.Issue.match, url)
  end

  defp is_pull_request?(url) do
    Regex.match?(CanvasAPI.Unfurl.GitHub.PullRequest.match, url)
  end
end
