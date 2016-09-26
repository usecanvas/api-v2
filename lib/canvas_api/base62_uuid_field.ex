defmodule CanvasAPI.Base62UUIDField do
  @moduledoc """
  A field that is encrypted in the database and decrypted when read out of it
  """

  @behaviour Ecto.Type

  def type, do: :string
  def cast(value), do: {:ok, to_string(value)}
  def dump(value), do: {:ok, value}
  def load(value), do: {:ok, value}
  def autogenerate, do: Base62UUID.generate
end
