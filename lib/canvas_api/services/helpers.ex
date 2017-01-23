defmodule CanvasAPI.Service.Helpers do
  @moduledoc """
  Helpers for common tasks in services.
  """

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
end
