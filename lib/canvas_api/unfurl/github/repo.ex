defmodule CanvasAPI.Unfurl.GitHub.Repo do
  @match ~r|\Ahttps?://(?:www\.)?github\.com/(?<owner>[^/]+)/(?<repo>[^/]+)/?\z|

  alias CanvasAPI.Unfurl.GitHub.API, as: GitHubAPI
  import Ecto.Query, only: [from: 2]

  def match, do: @match

  def unfurl(block, account: account) do
    with {:ok, %{body: body, status_code: 200}} <- do_get(account, block) do
      %CanvasAPI.Unfurl{
        id: block.id,
        title: body["full_name"],
        text: body["description"],
        thumbnail_url: get_in(body, ~w(owner avatar_url))
      }
    else
      _ -> nil
    end
  end

  defp do_get(account, block) do
    GitHubAPI.get_by(account, endpoint(block.meta["url"]))
  end

  defp endpoint(url) do
    %{"owner" => owner, "repo" => repo} = Regex.named_captures(@match, url)
    "/repos/#{owner}/#{repo}"
  end
end
