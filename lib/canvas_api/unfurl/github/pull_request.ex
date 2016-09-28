defmodule CanvasAPI.Unfurl.GitHub.PullRequest do
  @match ~r|\Ahttps://(?:www\.)?github\.com/(?<owner>[^/]+)/(?<repo>[^/]+)/pull/(?<pull_id>\d+)/?\z|

  alias CanvasAPI.{Block, Unfurl}
  alias Unfurl.GitHub.API, as: GitHubAPI

  def match, do: @match

  def unfurl(block = %Block{meta: %{"url" => url}}, account: account) do
    with {:ok, %{body: pull_body, status_code: 200}} <- do_get(account, pull_endpoint(url)),
         {:ok, %{body: issue_body, status_code: 200}} <- do_get(account, issue_endpoint(url)),
         body = Map.merge(pull_body, issue_body) do
      CanvasAPI.Unfurl.GitHub.Issue.unfurl_from_body(block, body)
    else
      {:ok, %{status_code: 404}} ->
        CanvasAPI.Unfurl.GitHub.Issue.unfurl_from_body(
          block,
          %{"title" => pull_endpoint(url) |> String.replace("/repos/", "")},
          false)
      _ ->
        nil
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

  defp do_get(account, url) do
    GitHubAPI.get_by(account, url)
  end
end
