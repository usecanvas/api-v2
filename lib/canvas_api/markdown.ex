defmodule CanvasAPI.Markdown do
  @moduledoc """
  A block-level Markdown parser for creating canvases from Markdown.
  """

  @cl_item ~r/\A(?<indent>\s*)[*+\-] \[(?<check>[xX ])\] (?<content>.+)\z/
  @code_fence ~r/\A```(?<lang>\S*)\z/
  @heading ~r/\A(?<hashes>\#{1,6})\s+(?<content>.+)\z/
  @horizontal_rule ~r/\A(?:- *)+\z/
  @image ~r[\Ahttps?://\S*\.(?:gif|jpg|jpeg|png)(?:\?\S*)?\z]i
  @ul_item ~r/\A(?<indent>\s*)[*+\-] (?<content>.+)\z/
  @url ~r[\Ahttps?://.*\z]i

  @spec parse(String.t) :: [map]
  def parse(lines) do
    lines
    |> String.split("\n")
    |> do_parse()
  end

  @spec do_parse([String.t], [map], Keyword.t) :: [map]
  defp do_parse(lines, result \\ [], state \\ [state: :null])

  # Final state: all lines parsed
  defp do_parse([], result, _state), do: Enum.reverse(result)

  # Title
  defp do_parse([line | tail] = lines, [], state: :null) do
    parsed = match_heading(line)
    if parsed && parsed[:meta][:level] == 1 do
      title =
        parsed
        |> Map.put(:type, "title")
        |> Map.delete(:meta)
      do_parse(tail, [title], state: :garbage)
    else
      do_parse(lines, [], state: :garbage)
    end
  end

  # Blank line
  defp do_parse(["" | tail], result, state: :garbage) do
    do_parse(tail, result, state: :garbage)
  end

  # Garbage state
  defp do_parse([line | tail], result, state: :garbage) do
    {parsed, new_state} =
      cond do
        parsed = match_heading(line) ->
          {parsed, state: :garbage}
        match = Regex.match?(@horizontal_rule, line) ->
          {%{type: "horizontal-rule"}, state: :garbage}
        match = match_code_fence(line) ->
          {%{type: "code", content: "", meta: %{language: elem(match, 1)}},
           state: :code}
        stripped_line = match_indented_code(line, "\t") ->
          {%{type: "code", content: stripped_line, meta: %{language: nil}},
           state: :code, indent: "\t"}
        stripped_line = match_indented_code(line, "    ") ->
          {%{type: "code", content: stripped_line, meta: %{language: nil}},
           state: :code, indent: "    "}
        parsed = match_list_item(line) ->
          {%{type: "list", blocks: [parsed]}, state: :list}
        Regex.match?(@image, line) ->
          {%{type: "image", meta: %{url: line}}, state: :garbage}
        Regex.match?(@url, line) ->
          {%{type: "url", meta: %{url: line}}, state: :garbage}
        true ->
          {%{type: "paragraph", content: line}, state: :garbage}
      end

    do_parse(tail, [parsed | result], new_state)
  end

  # Code state
  defp do_parse([line | tail] = lines, [code | result_tail] = result, state: :code, indent: indent) do
    if line = match_indented_code(line, indent) do
      content = "#{code[:content]}\n#{line}"
      code = Map.put(code, :content, content)
      do_parse(tail, [code | result_tail], state: :code, indent: indent)
    else
      do_parse(lines, result, state: :garbage)
    end
  end

  defp do_parse([line | tail], [code | result_tail] = result, state: :code) do
    if match_code_fence(line) do
      do_parse(tail, result, state: :garbage)
    else
      content =
        if code[:content] == "" do
          line
        else
          "#{code[:content]}\n#{line}"
        end
      code = Map.put(code, :content, content)
      do_parse(tail, [code | result_tail], state: :code)
    end
  end

  # List state
  defp do_parse([line | tail] = lines, [list | result_tail] = result, state: :list) do
    if parsed = match_list_item(line) do
      blocks = list[:blocks] ++ [parsed]
      list = Map.put(list, :blocks, blocks)
      do_parse(tail, [list | result_tail], state: :list)
    else
      do_parse(lines, result, state: :garbage)
    end
  end

  @spec match_indented_code(String.t, String.t) :: String.t | nil
  defp match_indented_code(line, indent) do
    if String.starts_with?(line, indent) do
      String.replace_prefix(line, indent, "")
    else
      nil
    end
  end

  @spec match_code_fence(String.t) :: {:ok, String.t | nil} | nil
  defp match_code_fence(line) do
    if match = Regex.named_captures(@code_fence, line) do
      lang = if match["lang"] == "", do: nil, else: match["lang"]
      {:ok, lang}
    end
  end

  @spec match_heading(String.t) :: map | nil
  defp match_heading(line) do
    if match = Regex.named_captures(@heading, line) do
      meta = %{level: String.length(match["hashes"])}
      %{type: "heading", content: match["content"], meta: meta}
    end
  end

  @spec match_list_item(String.t) :: map | nil
  defp match_list_item(line) do
    cond do
      match = Regex.named_captures(@cl_item, line) ->
        level = match["indent"] |> String.length |> div(2) |> Kernel.+(1)
        checked = match["check"] |> String.downcase |> String.contains?("x")
        meta = %{level: level, checked: checked}
        %{type: "checklist-item", content: match["content"], meta: meta}
      match = Regex.named_captures(@ul_item, line) ->
        level = match["indent"] |> String.length |> div(2) |> Kernel.+(1)
        meta = %{level: level}
        %{type: "unordered-list-item", content: match["content"], meta: meta}
      true ->
        nil
    end
  end
end
