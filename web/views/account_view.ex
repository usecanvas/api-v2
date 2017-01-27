defmodule CanvasAPI.AccountView do
  use CanvasAPI.Web, :view

  @intercom_secret System.get_env("INTERCOM_SECURE_SECRET")

  def render("show.json", %{account: account}) do
    %{data: render_one(account, CanvasAPI.AccountView, "account.json")}
  end

  def render("account.json", %{account: account}) do
    %{
      id: account.id,
      attributes: %{
        inserted_at: account.inserted_at,
        updated_at: account.updated_at,
        intercom_hash: intercom_hash(@intercom_secret, account.id)
      },
      relationships: %{
        teams: %{
          links: %{
            related: team_path(CanvasAPI.Endpoint, :index)
          }
        },
        ui_dismissals: %{
          links: %{
            related: ui_dismissal_path(CanvasAPI.Endpoint, :index)
          }
        }
      },
      type: "account"
    }
  end

  defp intercom_hash(nil, _), do: nil
  defp intercom_hash(secret, id) do
    :crypto.hmac(:sha256, secret, id)
    |> Base.encode16
    |> String.downcase
  end
end
