defmodule CanvasAPI.PulseEventService do
  @moduledoc """
  Service for viewing and manipulating pulse events.
  """

  use CanvasAPI.Web, :service
  alias CanvasAPI.PulseEvent

  @doc """
  Create a new pulse event for the given params and canvas.

  The creator must provide a canvas.

  Options:

  - `canvas`: `%Canvas{}` (**required**) The canvas the pulse event belongs to

  ## Examples

  ```elixir
  PulseEventService.create(
    %{provider_name: "GitHub"},
    canvas: canvas)
  ```
  """
  @spec create(map, Keyword.t) :: {:ok, %PulseEvent{}}
                                | {:error, Ecto.Changeset.t}
  def create(params, opts) do
    %PulseEvent{}
    |> PulseEvent.changeset(params)
    |> put_assoc(:canvas, opts[:canvas])
    |> Repo.insert
  end
end
