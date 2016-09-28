defmodule CanvasAPI.JSONEncoder do
  @moduledoc """
  A JSON encoder that prettifies its output.
  """

  def encode_to_iodata!(data) do
    Poison.encode_to_iodata!(data, pretty: true)
  end
end
