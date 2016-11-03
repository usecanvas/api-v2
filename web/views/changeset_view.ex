defmodule CanvasAPI.ChangesetView do
  use CanvasAPI.Web, :view

  @doc """
  Traverses and translates changeset errors.

  See `Ecto.Changeset.traverse_errors/2` and
  `CanvasAPI.ErrorHelpers.translate_error/1` for more details.
  """
  def translate_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, &translate_error/1)
  end

  def render("error.json", %{changeset: changeset}) do
    changeset
    |> translate_errors
    |> Enum.flat_map(&build_error/1)
    |> json_object(:errors)
  end

  defp build_error({key, errors}) do
    errors
    |> Enum.map(fn error ->
      %{
        code: "unprocessable_entity",
        detail: "#{key |> to_string |> String.capitalize} #{error}",
        source: %{pointer: "/data/attributes/#{key}"},
        status: Plug.Conn.Status.code(:unprocessable_entity) |> to_string,
        title: error
      }
    end)
  end
end
