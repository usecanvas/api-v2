defmodule CanvasAPI.Unfurl.GitHub do
  @moduledoc """
  An unfurl representing a GitHub repo, issue, or pull request.
  """

  alias CanvasAPI.Unfurl

  @provider_name "GitHub"
  @provider_url "https://github.com"
  @provider_icon_url(
    "https://s3.amazonaws.com/canvas-assets/provider-icons/github.png")

  def unfurl(block, account: account) do
    with mod when is_atom(mod) <- get_unfurl_mod(block),
         unfurl = %Unfurl{} <- mod.unfurl(block, account: account) do
      %CanvasAPI.Unfurl{
        unfurl |
          provider_name: @provider_name,
          provider_url: @provider_url,
          provider_icon_url: @provider_icon_url,
          url: block.meta["url"]
      }
    end
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
