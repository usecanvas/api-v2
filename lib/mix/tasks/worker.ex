defmodule Mix.Tasks.CanvasApi.Worker do
  use Mix.Task

  @moduledoc """
  Start an Exq worker.
  """

  @shortdoc "Start an Exq worker"

  def run(_) do
    Mix.Task.run("app.start", [])
    {:ok, _} = Application.ensure_all_started(:exq)
    Mix.Task.run("run", ["--no-halt"])
  end
end
