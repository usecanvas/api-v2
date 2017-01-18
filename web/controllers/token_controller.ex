defmodule CanvasAPI.TokenController do
  @moduledoc """
  A controller from token-related Canvas API requests.
  """

  alias CanvasAPI.TokenService
  use CanvasAPI.Web, :controller
  plug CanvasAPI.CurrentAccountPlug
  plug CanvasAPI.JSONAPIPlug

  @doc """
  Resopnd to a request to create a token.
  """
  @spec create(Plug.Conn.t, Plug.Conn.params) :: Plug.Conn.t
  def create(conn = %{private: %{parsed_request: parsed_request}}, _params) do
    parsed_request.attrs
    |> TokenService.create(parsed_request.opts)
    |> case do
      {:ok, token} ->
        created(conn, token: token)
      {:error, changeset} ->
        unprocessable_entity(conn, changeset)
    end
  end
end
