defmodule CanvasAPI.Service.Helpers do
  @moduledoc """
  Helpers for common tasks in services.
  """

  require Ecto.Query

  defmacro broadcast(channel, event, template, assigns \\ []) do
    quote do
      CanvasAPI.Endpoint.broadcast(
        unquote(channel),
        unquote(event),
        render(unquote(template), unquote(assigns)))
    end
  end

  defmacro render(template, assigns \\ []) do
    quote do
      view =
        __MODULE__
        |> Atom.to_string
        |> String.split(".")
        |> List.last
        |> String.replace("Service", "View")
      view_module = Module.concat([CanvasAPI, view])
      view_module.render(unquote(template), unquote(assigns) |> Enum.into(%{}))
    end
  end

  @spec maybe_lock(Ecto.Query.t) :: Ecto.Query.t
  def maybe_lock(query) do
    if CanvasAPI.Repo.in_transaction? do
      Ecto.Query.lock(query, "FOR UPDATE")
    else
      query
    end
  end
end
