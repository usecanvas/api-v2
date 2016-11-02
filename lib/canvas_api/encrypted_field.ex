defmodule CanvasAPI.EncryptedField do
  @moduledoc """
  A field that is encrypted in the database and decrypted when read out of it
  """

  import CanvasAPI.Encryption

  @behaviour Ecto.Type

  @spec type() :: :string
  def type, do: :string

  @spec cast(any) :: {:ok, String.t}
  def cast(value), do: {:ok, to_string(value)}

  @spec dump(String.t) :: {:ok, String.t}
  def dump(value), do: {:ok, value |> encrypt}

  @spec load(String.t) :: {:ok, String.t}
  def load(value), do: {:ok, value |> decrypt}
end
