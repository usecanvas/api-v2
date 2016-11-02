defmodule CanvasAPI.Base62UUIDField do
  @moduledoc """
  A field that is a base 62 UUID, which is a base-62-encoded v4 UUID.
  """

  @behaviour Ecto.Type

  @spec type() :: :string
  def type, do: :string

  @spec cast(any) :: {:ok, String.t}
  def cast(value), do: {:ok, to_string(value)}

  @spec dump(any) :: {:ok, any}
  def dump(value), do: {:ok, value}

  @spec load(any) :: {:ok, any}
  def load(value), do: {:ok, value}

  @spec autogenerate() :: Stirng.t
  def autogenerate, do: Base62UUID.generate
end
