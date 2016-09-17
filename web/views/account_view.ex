defmodule CanvasAPI.AccountView do
  use CanvasAPI.Web, :view

  def render("show.json", %{account: account}) do
    %{data: render_one(account, CanvasAPI.AccountView, "account.json")}
  end

  def render("account.json", %{account: account}) do
    %{
      id: account.id,
      attributes: %{
        inserted_at: account.inserted_at,
        updated_at: account.updated_at
      },
      relationships: %{
        teams: %{
          links: %{
            related: team_path(CanvasAPI.Endpoint, :index)
          }
        }
      },
      type: "account"
    }
  end
end
