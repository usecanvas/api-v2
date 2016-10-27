defmodule CanvasAPI.UUIDMatch do
  @moduledoc """
  Provides a pattern match for v4 UUIDs.
  """

  defmacro match_uuid do
    quote do
      <<_::64, ?-, _::32, ?-, ?4, _::24, ?-, _::32, ?-, _::96>>
    end
  end
end
