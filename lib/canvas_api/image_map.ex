defmodule CanvasAPI.ImageMap do
  @moduledoc """
  Converts image keys into a map of images.
  """

  @doc """
  Convert image keys into a map of images.
  """
  @spec image_map(map) :: map
  def image_map(map) do
    Enum.reduce(map, %{}, fn ({key, value}, images) ->
      key = if is_atom(key), do: Atom.to_string(key), else: key

      if String.starts_with?(key, "image_") do
        Map.put(images, key, value)
      else
        images
      end
    end)
  end
end
