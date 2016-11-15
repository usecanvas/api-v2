defmodule CanvasAPI.Canvas.Formatter do
  @moduledoc """
  Converts a canvas to a given format.
  """

  alias CanvasAPI.{Block, Canvas}

  @spec to_markdown(Canvas.t | Block.t) :: String.t
  def to_markdown(block_parent) do
    block_parent.blocks
    |> Enum.reduce("", &block_to_markdown/2)
    |> String.trim_trailing
  end

  @spec block_to_markdown(Block.t, String.t) :: String.t
  defp block_to_markdown(block = %Block{type: "title"}, _md) do
    "# #{block.content}\n\n"
  end

  defp block_to_markdown(block = %Block{type: "paragraph"}, md) do
    "#{md}#{block.content}\n\n"
  end

  defp block_to_markdown(block = %Block{type: "heading"}, md) do
    "#{md}#{leading_hashes(block)} #{block.content}\n\n"
  end

  defp block_to_markdown(block = %Block{type: "url"}, md) do
    "#{md}<#{URI.encode(block.meta["url"])}>\n\n"
  end

  defp block_to_markdown(block = %Block{type: "image"}, md) do
    "#{md}![](#{URI.encode(block.meta["url"])})\n\n"
  end

  defp block_to_markdown(block = %Block{type: "code"}, md) do
    "#{md}```#{block.meta["language"]}\n#{block.content}\n```\n\n"
  end

  defp block_to_markdown(block = %Block{type: "list"}, md) do
    "#{md}#{to_markdown(block)}\n\n"
  end

  defp block_to_markdown(block = %Block{type: "unordered-list-item"}, md) do
    "#{md}#{leading_spaces(block)}- #{block.content}\n"
  end

  defp block_to_markdown(block = %Block{type: "checklist-item"}, md) do
    check = if block.meta["checked"], do: "x", else: " "
    "#{md}#{leading_spaces(block)}- [#{check}] #{block.content}\n"
  end

  defp block_to_markdown(_, md), do: md

  @spec leading_hashes(Block.t) :: String.t
  defp leading_hashes(%Block{meta: %{"level" => level}}) do
    String.duplicate("#", level)
  end

  @spec leading_spaces(Block.t) :: String.t
  defp leading_spaces(%Block{meta: %{"level" => level}}) do
    String.duplicate("  ", level - 1)
  end
end
