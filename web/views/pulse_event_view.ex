defmodule CanvasAPI.PulseEventView do
  use CanvasAPI.Web, :view

  alias CanvasAPI.Endpoint

  def render("index.json", %{pulse_events: pulse_events}) do
    %{
      data: render_many(pulse_events, __MODULE__, "pulse_event.json")
    }
  end

  def render("pulse_event.json", %{pulse_event: event}) do
    %{
      id: event.id,
      attributes: %{
        provider_name: event.provider_name,
        provider_url: event.provider_url,
        referencer: event.referencer,
        type: event.type,
        url: event.url,
        inserted_at: event.inserted_at,
        updated_at: event.updated_at
      },
      relationships: %{
        canvas: %{
          data: %{id: event.canvas.id, type: "canvas"},
          links: %{
            related: team_canvas_path(
              Endpoint, :show, event.canvas.team_id, event.canvas.id)
          }
        }
      },
      type: "pulse-event"
    }
  end
end
