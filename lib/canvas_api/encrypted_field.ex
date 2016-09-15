defmodule CanvasAPI.EncryptedField do
  @moduledoc """
  A field that is encrypted in the database and decrypted when read out of it
  """

  import CanvasAPI.Encryption

  @behaviour Ecto.Type

  def type, do: :string
  def cast(value), do: {:ok, to_string(value)}
  def dump(value), do: {:ok, value |> encrypt}
  def load(value), do: {:ok, value |> decrypt}
end
