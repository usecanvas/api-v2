defmodule CanvasAPI.PulseEventServiceTest do
  use CanvasAPI.ModelCase

  alias CanvasAPI.PulseEventService, as: Service
  import CanvasAPI.Factory

  describe ".create" do
    test "returns a created PulseEvent" do
      {:ok, _pulse_event} =
        Service.create(
          %{provider_name: "GitHub",
            provider_url: "https://github.com",
            url: "https://github.com/usecanvas/pro-api",
            type: "mentioned",
            referencer: %{
              id: "ref_id",
              email: "user@example.dom"
            }}, canvas: insert(:canvas))
    end

    test "returns a changeset when invalid" do
      {:error, changeset} =
        Service.create(%{}, canvas: insert(:canvas))
      assert {:provider_name, {"can't be blank", []}} in changeset.errors
    end
  end
end
