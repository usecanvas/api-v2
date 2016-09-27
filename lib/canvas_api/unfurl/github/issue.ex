defmodule CanvasAPI.Unfurl.GitHub.Issue do
  @match ~r|\Ahttps://(?:www\.)?github\.com/(?<owner>[^/]+)/(?<repo>[^/]+)/issues/(?<issue_id>\d+)/?\z|

  alias CanvasAPI.{Block, Unfurl}
  alias Unfurl.GitHub.API, as: GitHubAPI
  alias Unfurl.{Field, Label}

  def match, do: @match

  def unfurl(block = %Block{meta: %{"url" => url}}) do
    with {:ok, %{body: body, status_code: 200}} <- do_get(block) do
      unfurl_from_body(url, body)
    else
      _ -> nil
    end
  end

  def unfurl_from_body(url, body) do
    %Unfurl{
      id: url,
      title: body["title"],
      text: issue_text(body),
      thumbnail_url: get_in(body, ~w(user avatar_url)),
      fields: [
        state_field(body),
        assignee_field(body)
      ],
      labels: labels(body["labels"])
    }
  end

  defp issue_text(body = %{"merged" => true}) do
    username = get_in(body, ~w(merged_by login))
    "##{body["number"]} merged #{time_ago(body["merged_at"])} by #{username}"
  end

  defp issue_text(body = %{"state" => "closed"}) do
    username = get_in(body, ~w(closed_by login))
    "##{body["number"]} closed #{time_ago(body["closed_at"])} by #{username}"
  end

  defp issue_text(body) do
    username = get_in(body, ~w(user login))
    "##{body["number"]} opened #{time_ago(body["created_at"])} by #{username}"
  end

  defp state_field(%{"merged" => true}) do
    %Field{title: "State", value: "merged", short: true}
  end

  defp state_field(body) do
    %Field{title: "State", value: body["state"], short: true}
  end

  defp assignee_field(%{"assignees" => assignees}) do
    title =
      case length(assignees) do
        1 -> "Assignee"
        _ -> "Assignees"
      end

    assignee_names =
      assignees
      |> Enum.map(fn assignee -> assignee["login"] end)
      |> Enum.join(", ")

    %Field{title: title, value: assignee_names, short: true}
  end

  defp do_get(block) do
    token = CanvasAPI.Unfurl.GitHub.get_token_for_block(block)
    GitHubAPI.get(endpoint(block.meta["url"]),
                  [{"authorization", "token #{token.token}"}])
  end

  defp endpoint(url) do
    %{"owner" => owner, "repo" => repo, "issue_id" => issue_id} =
      Regex.named_captures(@match, url)
    "/repos/#{owner}/#{repo}/issues/#{issue_id}"
  end

  defp labels(labels) do
    labels
    |> Enum.map(fn label ->
      %Label{color: "##{label["color"]}", value: label["name"]}
    end)
  end

  defp time_ago(time) do
    time
    |> Timex.parse!("{ISO:Extended}")
    |> Timex.from_now
  end
end
