defmodule CanvasAPI.Repo do
  use Ecto.Repo, otp_app: :canvas_api

  @doc """
  Reload a model by its ID.
  """
  def reload(model) do
    __MODULE__.get(model.__struct__, model.id)
  end
end
