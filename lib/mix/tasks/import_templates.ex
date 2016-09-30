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

  alias CanvasAPI.{Block, Canvas, Repo, User}
  import Ecto.Changeset

  def run(template_urls) when is_list(template_urls) do
    System.put_env("DATABASE_POOL_SIZE", "1")
    Mix.Task.run("app.start", [])

    user =
      Repo.get!(User, System.get_env("TEMPLATE_USER_ID"))
      |> Repo.preload([:team])

    Enum.map(template_urls, fn template ->
      import_template(template, user)
      |> Map.take([:id, :is_template, :blocks])
    end)
    |> Poison.encode!(pretty: true)
    |> IO.puts
  end

  defp import_template(template_url, user) do
    {:ok, %{body: body, status_code: 200}} = HTTPoison.get(template_url)

    json = Poison.decode!(body) |> Map.put("is_template", true)
    json = Map.put(json, "blocks", Enum.map(json["blocks"], &to_block_change/1))

    case json["id"] do
      nil -> do_import_template(Map.put(json, "id", Base62UUID.generate), user)
      id when is_binary(id) -> do_import_template(json, user)
    end
  end

  defp to_block_change(block_params) do
    %Block{id: block_params["id"]}
    |> Block.changeset(block_params)
  end

  defp do_import_template(json, user) do
    changeset =
      case Repo.get(Canvas, json["id"]) do
        nil -> %Canvas{id: json["id"]}
        canvas -> canvas |> Repo.preload([:creator, :team])
      end
      |> Canvas.changeset(json |> Map.delete("blocks"))
      |> put_embed(:blocks, json["blocks"])
      |> put_assoc(:creator, user)
      |> put_assoc(:team, user.team)
      |> Repo.insert_or_update!
  end
end
