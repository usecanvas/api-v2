defmodule CanvasAPI.Unfurl.Canvas do
  @moduledoc """
  An unfurled canvas, providing summary and progress information.
  """

  @provider_name "Canvas"
  @provider_icon_url(
    "https://s3.amazonaws.com/canvas-assets/provider-icons/canvas.png")
  @provider_url "https://usecanvas.com"

  @canvas_regex Regex.compile!("""
  \\A
  #{System.get_env("WEB_URL")}/ # Host
  [^/]+/                        # Team domain
  (?<id>[^/]{22})               # Canvas ID
  (?:\\?.+)?                    # Query
  (?:\\#[^\\?]+)?               # Document fragment
  \\z
  """, "x")

  alias CanvasAPI.{Block, CanvasService, Unfurl}
  alias Unfurl.Field

  @doc """
  Get a regular expression that matches a canvas URL.
  """
  @spec canvas_regex() :: Regex.t
  def canvas_regex, do: @canvas_regex

  @doc """
  Attempt to unfurl a URL pointing to a canvas into an `Unfurl` struct that
  contains a summary of the canvas.

  If the URL contains a `filter` query param, it will filter the canvas blocks
  and summarize them.

  If the URL contains a fragment, it will summarize only the canvas block
  whose ID matches the fragment (will return `nil` if no such block exists).
  """
  @spec unfurl(String.t, Keyword.t) :: Unfurl.t | nil
  def unfurl(url, account: account) do
    uri = URI.parse(url)
    with {team_id, id} = extract_canvas_info(uri.path),
         {:ok, canvas} <-
           CanvasService.show(id, account: account, team_id: team_id),
         query = URI.decode_query(uri.query || ""),
         filter = Map.get(query, "filter"),
         block_id = Map.get(query, "block"),
         blocks = canvas.blocks |> Enum.slice(1..-1) |> filter_blocks(filter),
         unfurl = %Unfurl{} <- do_unfurl(blocks, block_id: block_id) do
      unfurl
      |> Map.put(:id, url)
      |> Map.put(:provider_icon_url, @provider_icon_url)
      |> Map.put(:provider_name, @provider_name)
      |> Map.put(:provider_url, @provider_url)
      |> fn
           unfurl = %Unfurl{title: title} when is_binary(title) -> unfurl
           unfurl -> Map.put(unfurl, :title, canvas_title(canvas))
         end.()
      |> Map.put(:url, url)
    end
  end

  @spec do_fragment_unfurl(%Block{}, [%Block{}]) :: Unfurl.t
  defp do_fragment_unfurl(block, blocks) do
    blocks = get_fragment_blocks(block, blocks)
    unfurl =
      %Unfurl{
        text: canvas_summary(blocks),
        fields: progress_fields(blocks),
        type: "canvas:#{block.type}"}

    case block.type do
      "heading" ->
        unfurl |> Map.put(:title, block.content)
      _ ->
        unfurl
    end
  end

  @spec do_unfurl([%Block{}], Keyword.t) :: Unfurl.t |nil
  defp do_unfurl(blocks, block_id: block_id) when is_binary(block_id) do
    with block = %Block{} <- find_block_by_id(blocks, block_id) do
      do_fragment_unfurl(block, blocks)
    end
  end

  defp do_unfurl(blocks, _) do
    %Unfurl{
      text: canvas_summary(blocks),
      fields: progress_fields(blocks),
      type: "canvas"}
  end

  defp canvas_summary(blocks) do
    Enum.find_value(blocks, fn
      %Block{type: "title"} -> nil
      %Block{type: "heading"} -> nil
      %Block{type: "list", blocks: blocks} -> canvas_summary(blocks)
      %Block{content: content} -> content
    end)
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

  @spec extract_canvas_info(String.t) :: {String.t, String.t}
  defp extract_canvas_info(path) do
    path
    |> String.split("/")
    |> Enum.slice(-2..-1)
    |> List.to_tuple
  end

  @spec filter_blocks([%Block{}], String.t | nil, [%Block{}]) :: [%Block{}]
  defp filter_blocks(blocks, filter, list \\ [])
  defp filter_blocks(blocks, nil, _), do: blocks
  defp filter_blocks(blocks, filter, list) do
    blocks
    |> Enum.reduce(list, fn
      block = %Block{type: "list"}, list ->
        if Block.matches_filter?(block, filter) do
          list ++ [Map.put(block, :blocks, filter_blocks(block.blocks, filter))]
        else
          list
        end
      block, list ->
        if Block.matches_filter?(block, filter) do
          list ++ [block]
        else
          list
        end
    end)
  end

  @spec find_block_by_id([%Block{}], String.t) :: %Block{} | nil
  defp find_block_by_id(blocks, id) do
    Enum.find_value(blocks, fn
      block = %Block{id: ^id} -> block
      block = %Block{type: "list"} -> find_block_by_id(block.blocks, id)
      _ -> nil
    end)
  end

  @spec get_fragment_blocks(%Block{}, [%Block{}]) :: [%Block{}]
  defp get_fragment_blocks(%Block{type: "list", blocks: blocks}, _), do: blocks
  defp get_fragment_blocks(block = %Block{type: "heading", meta: %{"level" => level}}, blocks) do
    min_level = level + 1

    Enum.reduce_while(blocks, {[], :not_found}, fn
      ^block, {[], :not_found} ->
        {:cont, {[], :found}}
      _block, {[], :not_found} ->
        {:cont, {[], :not_found}}
      %Block{type: "heading", meta: %{"level" => level}}, {list, :found}
        when level < min_level ->
          {:halt, {list, :found}}
      block, {list, :found} ->
        {:cont, {list ++ [block], :found}}
    end)
    |> elem(0)
  end
  defp get_fragment_blocks(block, _), do: [block]
end
