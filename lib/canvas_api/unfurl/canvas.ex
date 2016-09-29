defmodule CanvasAPI.Unfurl.Canvas do
  @moduledoc """
  An unfurled canvas, providing summary and progress information.
  """

  @lint {Credo.Check.Readability.MaxLineLength, false}
  @match ~r|\Ahttps://[^\.]+\.slack\.com/archives/(?<channel>[^/]+)/p(?<timestamp>\d+)\z|

  @canvas_regex Regex.compile!(
    "\\Ahttps?://#{System.get_env("WEB_HOST")}/[^/]+/(?<id>[^/]{22})\\z")

  alias CanvasAPI.{Block, Canvas, Repo, Unfurl}
  alias Unfurl.Field

  def unfurl(block, _opts) do
    %{"id" => id, "team_domain" => team_domain} =
      Map.take(block.meta, ~w(id team_domain))

    if canvas = Repo.get(Canvas, id) do
      %Unfurl{
        id: block.id,
        title: canvas_title(canvas),
        text: canvas_summary(canvas),
        provider_name: "Canvas",
        provider_url: "https://usecanvas.com",
        url: "https://pro.usecanvas.com/#{team_domain}/#{id}",
        fields: [
          progress_field(canvas)
        ]
      }
    else
      %Unfurl{
        id: block.id,
        title: "https://pro.usecanvas.com/#{team_domain}/#{id}",
        provider_name: "Canvas",
        provider_url: "https://usecanvas.com",
        url: block.meta["url"],
      }
    end
  end

  def canvas_regex, do: @canvas_regex

  defp canvas_summary(canvas) do
    first_content_block =
      canvas.blocks
      |> Enum.at(1)

    case first_content_block do
      %Block{blocks: [block | _]} ->
        block.content
      %Block{content: content} ->
        String.slice(content, 0..140)
      nil ->
        ""
    end
  end

  defp canvas_title(canvas) do
    canvas.blocks
    |> Enum.at(0)
    |> Map.get(:content)
  end

  defp progress_field(canvas) do
    {complete, total} = do_progress_field(canvas.blocks)
    progress = if total > 0, do: (complete / total * 100) |> Float.round(2)
    %Field{title: "progress", value: progress, short: true}
  end

  defp do_progress_field(blocks, progress \\ {0, 0}) do
    blocks
    |> Enum.reduce(progress, fn
      (%Block{blocks: child_blocks}, progress) when length(child_blocks) > 0 ->
        do_progress_field(child_blocks, progress)
      (block = %Block{type: "checklist-item"}, progress) ->
        if block.meta["checked"] do
          {elem(progress, 0) + 1, elem(progress, 1) + 1}
        else
          {elem(progress, 0), elem(progress, 1) + 1}
        end
      (_, progress) ->
        progress
    end)
  end
end
