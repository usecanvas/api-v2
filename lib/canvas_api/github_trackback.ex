defmodule CanvasAPI.GitHubTrackback do
  @moduledoc """
  A reference to a canvas in GitHub
  """

  use CanvasAPI.Trackback
  alias CanvasAPI.{PulseEvent, PulseEventService}

  @provider_name "GitHub"
  @provider_url "https://github.com"

  @doc """
  Adds a GitHub trackback to a canvas.
  """
  @spec add(map, String.t | nil) :: {:ok, %PulseEvent{}} | :ok
  def add(params, team_id \\ nil)

  def add(%{"action" => "created", "comment" => comment}, _team_id) do
    with canvas = %Canvas{} <- get_canvas(comment["body"]) do
      github_object_pulse_event(comment, canvas)
    end
  end

  def add(%{"action" => "submitted", "review" => review}, _team_id) do
    with canvas = %Canvas{} <- get_canvas(review["body"]) do
      github_object_pulse_event(review, canvas)
    end
  end

  def add(%{"action" => "opened", "issue" => issue}, _team_id) do
    with canvas = %Canvas{} <- get_canvas(issue["title"] <> issue["body"]) do
      github_object_pulse_event(issue, canvas)
    end
  end

  def add(%{"action" => "opened", "pull_request" => pr}, _team_id) do
    with canvas = %Canvas{} <- get_canvas(pr["title"] <> pr["body"]) do
      github_object_pulse_event(pr, canvas)
    end
  end

  def add(%{"commits" => commits}, _team_id) do
    Enum.each(commits, &add_commit/1)
  end

  def add(_, _), do: nil

  # Generate a pulse event from a GitHub object
  @spec github_object_pulse_event(map, %Canvas{}) :: {:ok, %PulseEvent{}}
                                                   | {:error, Ecto.Changeset.t}
  defp github_object_pulse_event(object, canvas) do
    referencer = github_user_referencer_params(object["user"])

    PulseEventService.create(
      %{
        provider_name: @provider_name,
        provider_url: @provider_url,
        type: "reference_added",
        url: object["html_url"],
        referencer: referencer},
      canvas: canvas)
  end

  # Get referencer params from a GitHub user
  @spec github_user_referencer_params(map) :: map
  defp github_user_referencer_params(user) do
    %{id: to_string(user["id"]),
      avatar_url: user["avatar_url"],
      name: "@#{user["login"]}",
      url: user["html_url"]}
  end

  # Add a commit trackback
  @spec add_commit(map) :: {:ok, %PulseEvent{}}
                         | {:error, Ecto.Changeset.t}
                         | nil
  defp add_commit(commit) do
    with canvas = %Canvas{} <- get_canvas(commit["message"]) do
      author = commit["author"]

      PulseEventService.create(
        %{
          provider_name: @provider_name,
          provider_url: @provider_url,
          type: "mentioned",
          url: commit["url"],
          referencer: %{
            id: author["email"],
            avatar_url: AvatarURL.create(author["email"]),
            email: author["email"],
            name: author["name"],
            url: "mailto:#{author["email"]}"}},
        canvas: canvas)
    end
  end
end
