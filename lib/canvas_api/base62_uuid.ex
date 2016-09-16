defmodule CanvasAPI.Base62UUID do
  @moduledoc """
  A base 62-encoded v4 UUID.
  """

  alias Ecto.UUID

  @length 22

  def generate do
    UUID.generate |> encode
  end

  defp encode(uuid) do
    uuid
    |> String.replace("-", "")
    |> String.to_integer(16)
    |> Base62.encode
    |> ensure_length
  end

  defp ensure_length(encoded) when byte_size(encoded) == @length, do: encoded
  defp ensure_length(encoded) do
    difference = @length - String.length(encoded)
    String.duplicate("0", difference) <> encoded
  end
end
