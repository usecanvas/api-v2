defmodule CanvasAPI.AvatarURL do
  @moduledoc """
  Generate an avatar URL from an email.
  """

  @doc """
  Generate an Gravatar avatar URL from an email.
  """
  @spec create(email :: String.t) :: String.t
  def create(email) do
    email_hash =
      :crypto.hash(:md5, String.downcase(email))
      |> Base.encode16(case: :lower)

    "https://www.gravatar.com/avatar/#{email_hash}"
  end
end
