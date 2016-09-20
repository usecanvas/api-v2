defmodule CanvasAPI.Unfurl.GitHub do
  def unfurl(url) do
    with mod when is_atom(mod) <- get_unfurl_mod(url),
         unfurl when not is_nil(unfurl) <- mod.unfurl(url) do
      %CanvasAPI.Unfurl{
        unfurl |
          provider_name: "GitHub",
          provider_url: "https://github.com",
          provider_icon_url: "https://s3.amazonaws.com/canvas-assets/provider-icons/github.png"
      }
    end
  end

  defp get_unfurl_mod(url) do
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
