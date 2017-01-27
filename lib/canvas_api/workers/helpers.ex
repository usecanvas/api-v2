defmodule CanvasAPI.Worker.Helpers do
  @moduledoc """
  A module of helper functions for job workers.
  """

  defmacro __using__(_) do
    quote do
      @doc """
      React to a notify job.
      """
      @spec perform(String.t, [any]) :: any
      def perform(func, args) do
        apply(__MODULE__, String.to_atom(func), args)
      end

      @doc """
      Call a module function, delayed.
      """
      @spec delay({atom, [any]}, Keyword.t) :: any
      def delay({func, args}, opts \\ []) do
        Exq.Enqueuer.enqueue_in(
          CanvasAPI.Queue.Enqueuer,
          "default",
          Keyword.get(opts, :delay, 0),
          __MODULE__,
          [to_string(func), args])
      end
    end
  end
end
