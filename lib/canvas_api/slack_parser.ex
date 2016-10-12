defmodule CanvasAPI.SlackParser do
  @moduledoc """
  Provides functionality for parsing Slack messages.
  """

  @doc """
  Convert a Slack message to plain text by stripping brackets and
  leaving only link text and labels.

  ## Examples

      iex> CanvasAPI.SlackParser.to_text("Foo <bar>")
      "Foo bar"

      iex> CanvasAPI.SlackParser.to_text("Foo <!here|@here> Bar")
      "Foo @here Bar"

      iex> CanvasAPI.SlackParser.to_text("Foo <https://www.example.com>")
      "Foo https://www.example.com"
  """
  @spec to_text(String.t, String.t, Keyword.t) :: String.t
  def to_text(message, result \\ "", state \\ [state: :garbage])

  def to_text("", result, state: :garbage),
    do: result

  def to_text("", result, rem: rem),
    do: result <> rem

  def to_text(<<?<, tail::binary>>, result, state: :garbage),
    do: tail |> to_text(result, state: :bracket, rem: "")

  def to_text(<<char::binary-size(1), tail::binary>>, result, state: :garbage),
    do: tail |> to_text(result <> char, state: :garbage)

  def to_text(<<?!, tail::binary>>, result, state: :bracket, rem: rem),
    do: tail |> to_text(result, state: :bracket, rem: rem)

  def to_text(<<?|, tail::binary>>, result, state: :bracket, rem: _rem),
    do: tail |> to_text(result, state: :bracket, rem: "")

  def to_text(<<?>, tail::binary>>, result, state: :bracket, rem: rem),
    do: tail |> to_text(result <> rem, state: :garbage)

  def to_text(<<char::binary-size(1), tail::binary>>, result, state: :bracket, rem: rem),
    do: tail |> to_text(result, state: :bracket, rem: rem <> char)
end
