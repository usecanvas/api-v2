defmodule CanvasAPI.Unfurl.GitHub.PullRequest do
  @match ~r|\Ahttps://(?:www\.)?github\.com/(?<owner>[^/]+)/(?<repo>[^/]+)/pull/(?<pull_id>\d+)/?\z|

  alias CanvasAPI.{Block, Unfurl}
  alias Unfurl.GitHub.API, as: GitHubAPI

  def match, do: @match

  def unfurl(block = %Block{meta: %{"url" => url}}) do
    with {:ok, %{body: pull_body, status_code: 200}} <- do_get(block, pull_endpoint(url)),
         {:ok, %{body: issue_body, status_code: 200}} <- do_get(block, issue_endpoint(url)),
         body = Map.merge(pull_body, issue_body) do
      CanvasAPI.Unfurl.GitHub.Issue.unfurl_from_body(url, body)
    else
      _ -> nil
    end
  end

  defp issue_endpoint(url) do
    %{"owner" => owner, "repo" => repo, "pull_id" => pull_id} =
      Regex.named_captures(@match, url)
    "/repos/#{owner}/#{repo}/issues/#{pull_id}"
  end

  defp pull_endpoint(url) do
    %{"owner" => owner, "repo" => repo, "pull_id" => pull_id} =
      Regex.named_captures(@match, url)
    "/repos/#{owner}/#{repo}/pulls/#{pull_id}"
  end

  defp do_get(block, url) do
    GitHubAPI.get_by(block.meta["creator_id"], url)
  end
end
