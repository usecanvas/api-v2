defmodule CanvasAPI.Unfurl.GitHub.Repo do
  @match ~r|\Ahttps?://(?:www\.)?github\.com/(?<owner>[^/]+)/(?<repo>[^/]+)/?\z|

  alias CanvasAPI.Unfurl.GitHub.API, as: GitHubAPI

  def match, do: @match

  def unfurl(url) do
    with {:ok, %{body: body, status_code: 200}} <- GitHubAPI.get(endpoint(url)) do
      %CanvasAPI.Unfurl{
        id: url,
        title: body["full_name"],
        text: body["description"],
        thumbnail_url: get_in(body, ~w(owner avatar_url))
      }
    else
      _ -> nil
    end
  end

  defp endpoint(url) do
    %{"owner" => owner, "repo" => repo} = Regex.named_captures(@match, url)
    "/repos/#{owner}/#{repo}"
  end
end
