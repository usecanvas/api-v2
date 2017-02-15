defmodule CanvasAPI.ExportService do
  @moduledoc """
  Service for getting Canvas data exports
  """

  alias CanvasAPI.{Canvas, CanvasService, UserService}

  @type export :: {:zip.filename, String.t}

  @doc """
  Get an export for a given team.
  """
  @spec get(String.t) :: {:ok, export} | {:error, any}
  def get(encoded_token) do
    with {:ok, user_id} <- validate_token(encoded_token),
         {:ok, user} <- UserService.get(user_id),
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

  @doc """
  Get an export token.
  """
  @spec get_token(String.t, String.t) :: {:ok, String.t} | {:error, any}
  def get_token(account, team_domain) do
    with {:ok, user} <-
           UserService.find_by_team(account, team_domain: team_domain) do
      token =
        CanvasAPI.Endpoint
        |> Phoenix.Token.sign("export", user.id)
        |> Base.url_encode64(padding: false)
      {:ok, token}
    end
  end

  @spec validate_token(String.t) :: {:ok, String.t} | {:error, any}
  defp validate_token(encoded_token) do
    with {:ok, token} <- Base.url_decode64(encoded_token, padding: false) do
      Phoenix.Token.verify(
        CanvasAPI.Endpoint,
        "export",
        token,
        max_age: 600)
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
