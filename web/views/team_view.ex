defmodule CanvasAPI.TeamView do
  use CanvasAPI.Web, :view

  def render("index.json", %{teams: teams}) do
    %{data: render_many(teams, CanvasAPI.TeamView, "team.json")}
  end

  def render("team.json", %{team: team}) do
    %{
      id: team.id,
      attributes: %{
        name: team.name,
        image_url: team.image_url,
        inserted_at: team.inserted_at,
        updated_at: team.updated_at
      },
      type: "teams"
    }
  end
end
