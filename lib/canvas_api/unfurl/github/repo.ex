defmodule CanvasAPI.Unfurl.GitHub.Repo do
  @match ~r|\Ahttps?://(?:www\.)?github\.com/(?<owner>[^/]+)/(?<repo>[^/]+)/?\z|

  alias CanvasAPI.Unfurl.GitHub.API, as: GitHubAPI

  def match, do: @match

  def unfurl(url, account: account) do
    with {:ok, %{body: body, status_code: 200}} <- do_get(account, url) do
      %CanvasAPI.Unfurl{
        id: url,
        title: body["full_name"],
        text: body["description"],
        thumbnail_url: get_in(body, ~w(owner avatar_url))
      }
    else
      {:ok, _} ->
        %CanvasAPI.Unfurl{
          id: url,
          title: String.replace(endpoint(url), "/repos/", ""),
          text: nil,
          thumbnail_url: nil,
          fetched: false
        }
      _ ->
        nil
    end
  end

  defp do_get(account, url) do
    GitHubAPI.get_by(account, endpoint(url))
  end

  defp endpoint(url) do
    %{"owner" => owner, "repo" => repo} = Regex.named_captures(@match, url)
    "/repos/#{owner}/#{repo}"
  end
end
