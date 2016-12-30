defmodule CanvasAPI.OpService do
  @moduledoc """
  A service for viewing and manipulating ops.
  """

  use CanvasAPI.Web, :service
  alias CanvasAPI.Op

  @preload [:canvas]

  @doc """
  List ops for a given canvas.

  Options:

  - `canvas`: `Canvas.t` (**required**) The canvas to fetch ops for

  ## Examples

  ```elixir
  OpService.list(canvas: canvas)
  ```
  """
  @spec list(Keyword.t) :: [Op.t]
  def list(canvas: canvas) do
    from(assoc(canvas, :ops),
         order_by: [asc: :version],
         preload: ^@preload)
    |> Repo.all
  end
end
