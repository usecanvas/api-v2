defmodule Mix.Tasks.CanvasApi.VerifyFuzzer do
  @moduledoc """
  Verify a canvas that had a ShareDB fuzzer run on it.

  ## Examples

      mix canvas_api.verify_fuzzer 0uP6L5iDsi5xI1xrN7v0Z3
  """

  @shortdoc "Verify a fuzzer canvas"

  require Logger

  use Mix.Task
  alias CanvasAPI.{Canvas, Repo}

  defstruct key: "",
            in_order: true,
            min: nil,
            max: nil,
            count: 0

  def run([id]) do
    Mix.Task.run("app.start", [])

    Canvas
    |> Repo.get(id)
    |> verify_fuzzed_canvas
  end

  defp verify_fuzzed_canvas(nil) do
   Logger.error("No canvas found")
   exit({:shutdown, 1})
  end

  defp verify_fuzzed_canvas(canvas) do
    canvas
    |> Map.get(:blocks)
    |> Enum.at(1)
    |> Map.get(:content)
    |> String.split(" ")
    |> Enum.filter(&(String.length(&1) > 0))
    |> Enum.group_by(&chunk_key/1, &chunk_value/1)
    |> Enum.map(&verify_chunks/1)
    |> Enum.each(fn struct -> struct |> inspect |> Logger.info end)
  end

  defp chunk_key(chunk), do: chunk |> split_chunk |> Enum.at(0)

  defp chunk_value(chunk),
    do: chunk |> split_chunk |> Enum.at(1) |> String.to_integer

  defp split_chunk(chunk), do: String.split(chunk, ".")

  defp verify_chunks({key, vectors}),
    do: Enum.reduce(vectors, %__MODULE__{key: key}, &verify_chunk/2)

  defp verify_chunk(chunk, struct) do
    struct
    |> check_min(chunk)
    |> check_max(chunk)
    |> check_order(chunk)
    |> update_count(chunk)
  end

  defp check_min(struct = %{min: nil}, chunk),
    do: %{struct | min: chunk}
  defp check_min(struct = %{min: min}, chunk) when chunk < min,
    do: %{struct | min: chunk}
  defp check_min(struct, _),
    do: struct

  defp check_max(struct = %{max: nil}, chunk),
    do: %{struct | max: chunk}
  defp check_max(struct = %{max: max}, chunk) when chunk > max,
    do: %{struct | max: chunk}
  defp check_max(struct, _),
    do: struct

  defp update_count(struct = %{count: count}, _),
    do: %{struct | count: count + 1}

  defp check_order(struct = %{in_order: false}, _),
    do: struct
  defp check_order(struct = %{count: count}, count),
    do: struct
  defp check_order(struct = %{count: _}, _),
    do: %{struct | in_order: false}
end
