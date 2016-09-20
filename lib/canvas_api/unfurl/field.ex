defmodule CanvasAPI.Unfurl.Field do
  defstruct title: nil, value: nil, short: false

  @type t :: %__MODULE__{
    short: boolean,
    title: String.t | nil,
    value: String.t | nil
  }
end
