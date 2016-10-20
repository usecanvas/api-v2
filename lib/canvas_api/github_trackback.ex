defmodule CanvasAPI.GitHubTrackback do
  @moduledoc """
  A reference to a canvas in GitHub
  """

  use CanvasAPI.Trackback

  @provider_name "GitHub"
  @provider_url "https://github.com"

  @doc """
  Adds a GitHub trackback to a canvas.
  """
  def add(%{"commits" => commits}, team_id) do
    with team = %Team{} <- get_team(team_id) do
      commits
      |> Enum.each(& add_commit(&1, team))
    end
  end

  def add(%{"comment" => comment, "action" => "created"}, team_id) do
    with team = %Team{} <- get_team(team_id),
         canvas = %Canvas{} <- get_canvas(comment["body"]) do
      author = comment["user"]

      %PulseEvent{}
      |> PulseEvent.changeset(%{
           provider_name: @provider_name,
           provider_url: @provider_url,
           type: "mentioned",
           url: comment["html_url"],
           referencer: %{
             id: to_string(author["id"]),
             avatar_url: author["avatar_url"],
             name: "@#{author["login"]}",
             url: author["html_url"]
           }})
      |> put_assoc(:canvas, canvas)
      |> Repo.insert!
    end
  end

  def add(%{"review" => review, "action" => "submitted"}, team_id) do
    add(%{"issue" => review, "action" => "opened"}, team_id)
  end

  def add(%{"issue" => issue, "action" => "opened"}, team_id) do
    with team = %Team{} <- get_team(team_id),
         canvas = %Canvas{} <- get_canvas(issue["body"]) do
      author = issue["user"]

      %PulseEvent{}
      |> PulseEvent.changeset(%{
           provider_name: @provider_name,
           provider_url: @provider_url,
           type: "mentioned",
           url: issue["html_url"],
           referencer: %{
             id: to_string(author["id"]),
             avatar_url: author["avatar_url"],
             name: "@#{author["login"]}",
             url: author["html_url"]
           }})
      |> put_assoc(:canvas, canvas)
      |> Repo.insert!
    end
  end

  def add(%{"pull_request" => pull_request, "action" => "opened"}, team_id) do
    add(%{"issue" => pull_request, "action" => "opened"}, team_id)
  end

  def add(_, _), do: nil

  defp add_commit(commit, team) do
    with canvas = %Canvas{} <- get_canvas(commit["message"]) do
      author = commit["author"]

      %PulseEvent{}
      |> PulseEvent.changeset(%{
           provider_name: @provider_name,
           provider_url: @provider_url,
           type: "mentioned",
           url: commit["url"],
           referencer: %{
             id: author["email"],
             avatar_url: AvatarURL.create(author["email"]),
             email: author["email"],
             name: author["name"],
             url: "mailto:#{author["email"]}"
           }})
      |> put_assoc(:canvas, canvas)
      |> Repo.insert!
    end
  end

  defp get_team(team_id) do
    Repo.get(Team, team_id)
  end
end
