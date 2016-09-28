defmodule CanvasAPI.Unfurl.Field do
  @moduledoc """
  A field in an unfurl that can be used to display meta-information about the
  unfurl.
  """

  defstruct title: nil, value: nil, short: false

  @type t :: %__MODULE__{
    short: boolean,
    title: String.t | nil,
    value: String.t | nil
  }
end
