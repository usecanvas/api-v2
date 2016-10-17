defmodule CanvasAPI.Unfurl.Canvas do
  @moduledoc """
  An unfurled canvas, providing summary and progress information.
  """

  @provider_name "Canvas"
  @provider_icon_url(
    "https://s3.amazonaws.com/canvas-assets/provider-icons/canvas.png")
  @provider_url "https://usecanvas.com"

  @canvas_regex Regex.compile! """
  \\A#{System.get_env("WEB_URL")}/
  [^/]+/
  (?<id>[^/]{22})
  (?:#[^\\?]+)?
  (?:\\?.+)?
  \\z
  """
  |> String.replace("\n", "")

  alias CanvasAPI.{Block, Canvas, Repo, Unfurl}
  alias Unfurl.Field

  def unfurl(url, _opts) do
    with id when is_binary(id) <- extract_canvas_id(url),
         canvas = %Canvas{} <- Repo.get(Canvas, id) |> Repo.preload([:team]) do

      blocks = filter_blocks(canvas.blocks, get_query(url)["filter"])

      %Unfurl{
        id: url,
        title: canvas_title(canvas),
        text: canvas_summary(blocks),
        provider_name: @provider_name,
        provider_icon_url: @provider_icon_url,
        provider_url: @provider_url,
        url: "#{System.get_env("WEB_URL")}/#{canvas.team.domain}/#{id}",
        fields: progress_fields(blocks)
      }
    end
  end

  def canvas_regex, do: @canvas_regex

  defp canvas_summary(blocks) do
    first_content_block = Enum.at(blocks, 0)

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

  defp progress_fields(blocks) do
    {complete, total} = blocks |> get_progress

    [%Field{title: "Tasks Complete", value: complete, short: true},
     %Field{title: "Tasks Total", value: total, short: true}]
  end

  defp get_progress(blocks, progress \\ {0, 0}) do
    blocks
    |> Enum.reduce(progress, fn
      (%Block{blocks: child_blocks}, progress) when length(child_blocks) > 0 ->
        get_progress(child_blocks, progress)
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

  defp filter_blocks(blocks, term, list \\ [])

  defp filter_blocks(blocks, nil, _), do: blocks

  defp filter_blocks(blocks, filter, list) do
    blocks
    |> Enum.reduce(list, fn block, list ->
      cond do
        block.type == "list" ->
          filter_blocks(block.blocks, filter, list)
        Block.matches_filter?(block, filter) ->
          list ++ [block]
        true ->
          list
      end
    end)
  end

  defp extract_canvas_id(url) do
    with match when is_map(match) <- Regex.named_captures(@canvas_regex, url) do
      match["id"]
    end
  end

  defp get_query(url) do
    url
    |> URI.parse
    |> Map.get(:query)
    |> Kernel.||("")
    |> URI.decode_query
  end
end
