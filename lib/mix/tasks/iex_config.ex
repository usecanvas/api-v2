defmodule Mix.Tasks.CanvasApi.IexConfig do
  use Mix.Task

  @moduledoc """
  Generate a new IEX configuration from the existing models.
  Import templates from URLs. The URL must return a 200 status code and a body
  that is just an array of blocks represented as JSON.

  ## Examples

      mix canvas_api.iex_config
  """

  @shortdoc "Generate an IEX config from existing models."

  def run(_) do
    ecto_import = "import Ecto.Query, only: [from: 2]"

    mixexs =
      Path.join(["mix.exs"])
      |> File.read!

    namespace =
      Regex.run(~r{defmodule\s+(\w+)\.}, mixexs)
      |> List.last

    repo_alias = "alias #{namespace}.Repo"

    models =
      Enum.map Path.wildcard("web/models/*.ex"), fn m ->
        Regex.run(~r{models/(\w+).ex}, m)
        |> List.last
        |> String.split("_")
        |> Enum.map(& String.capitalize &1)
        |> Enum.join("")
      end

    aliases =
      models
      |> Enum.map(& "alias #{namespace}.#{&1}")
      |> Enum.join("\n")

    iexexs_txt = "#{ecto_import}\n\n#{repo_alias}\n\n#{aliases}\n"

    Path.join([".iex.exs"])
    |> File.write(iexexs_txt, [:append])
  end
end
