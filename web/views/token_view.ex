defmodule CanvasAPI.TokenView do
  @moduledoc """
  A view for rendering access tokens.
  """

  alias CanvasAPI.PersonalAccessToken
  use CanvasAPI.Web, :view

  def render("show.json", %{token: token}) do
    %{
      data: render_one(token, __MODULE__, "token.json")
    }
  end

  def render("token.json", %{token: token}) do
    %{
      id: token.id,
      attributes: %{
        token: PersonalAccessToken.formatted_token(token),
        expires_at: token.expires_at,
        inserted_at: token.inserted_at,
        updated_at: token.updated_at
      },
      type: "token"
    }
  end
end
