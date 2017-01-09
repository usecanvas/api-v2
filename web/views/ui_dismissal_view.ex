defmodule CanvasAPI.UIDismissalView do
  use CanvasAPI.Web, :view

  def render("index.json", %{ui_dismissals: dismissals}) do
    %{
      data: render_many(dismissals, __MODULE__, "dismissal.json")
    }
  end

  def render("show.json", %{ui_dismissal: dismissal}) do
    %{
      data: render_one(dismissal, __MODULE__, "dismissal.json")
    }
  end

  def render("dismissal.json", %{ui_dismissal: dismissal}) do
    %{
      id: dismissal.id,
      attributes: %{
        identifier: dismissal.identifier,
        inserted_at: dismissal.inserted_at,
        updated_at: dismissal.updated_at
      },
      type: "ui-dismissal"
    }
  end
end
