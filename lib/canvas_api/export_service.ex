defmodule CanvasAPI.ExportService do
  @moduledoc """
  Service for getting Canvas data exports
  """

  alias CanvasAPI.{Canvas, CanvasService, UserService}

  @type export :: {:zip.filename, String.t}

  @doc """
  Get an export for a given team.
  """
  @spec get(String.t, Keyword.t) :: {:ok, export} | {:error, any}
  def get(team_id, account: account) do
    with {:ok, user} <- UserService.find_by_team(account, team_id: team_id),
         canvases <- CanvasService.list(user: user) do
      archive_name = "canvas-export-#{user.team.domain}"

      files =
        canvases
        |> Enum.chunk(export_concurrency, export_concurrency, [])
        |> Enum.map(&export_canvases/1)
        |> List.flatten

      zip_files =
        canvases
        |> Enum.map(&(String.to_charlist("#{archive_name}/#{&1.id}.md")))
        |> Enum.zip(files)

      "#{archive_name}.zip"
      |> :zip.zip([readme(archive_name) | zip_files], [:memory])
    end
  end

  @spec export_canvases([Canvas.t]) :: [export]
  defp export_canvases(canvases) do
    canvases
    |> Enum.map(&Task.async(fn -> Canvas.Formatter.to_markdown(&1) end))
    |> Enum.map(&Task.await/1)
  end

  @spec export_concurrency :: pos_integer
  defp export_concurrency,
    do: String.to_integer(System.get_env("EXPORT_CONCURRENCY") || "10")

  @spec readme(String.t) :: export
  defp readme(archive_name) do
    content = """
    This is an export of the Canvas data.
    """

    {String.to_charlist("#{archive_name}/README.md"), content}
  end
end
