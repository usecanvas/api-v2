defmodule Mix.Tasks.CanvasApi.ImportTemplates do
  use Mix.Task

  @moduledoc """
  Import templates from URLs. The URL must return a 200 status code and a body
  that is just an array of blocks represented as JSON.

  ## Examples

      mix canvas_api.import_templates https://example.com/blocks.json

      mix canvas_api.import_templates \\
        https://example.com/blocks-1.json \\
        https://example.com/blocks-2.json \\
        https://example.com/blocks-3.json
  """

  @shortdoc "Import templates from URLs"

  alias CanvasAPI.{Canvas, Repo, User}
  import Ecto.Changeset

  def run(template_urls) when is_list(template_urls) do
    System.put_env("DATABASE_POOL_SIZE", "1")
    Mix.Task.run("app.start", [])

    user =
      Repo.get!(User, System.get_env("TEMPLATE_USER_ID"))
      |> Repo.preload([:team])

    Enum.each(template_urls, fn template -> import_template(template, user) end)
  end

  defp import_template(template_url, user) do
    {:ok, %{body: body, status_code: 200}} = HTTPoison.get(template_url)
    json = Poison.decode!(body) |> Map.put("is_template", true)

    Canvas.changeset(%Canvas{}, json)
    |> put_assoc(:creator, user)
    |> put_assoc(:team, user.team)
    |> Repo.insert!
  end
end
