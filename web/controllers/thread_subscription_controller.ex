defmodule CanvasAPI.ThreadSubscriptionController do
  @moduledoc """
  A controller for handling thread subscription HTTP reqeuests.
  """

  use CanvasAPI.Web, :controller

  alias CanvasAPI.ThreadSubscriptionService

  plug CanvasAPI.CurrentAccountPlug
  plug CanvasAPI.JSONAPIPlug when action in [:upsert]

  @doc """
  Create or update a thread subscription from a request.
  """
  @spec upsert(Plug.Conn.t, Plug.Conn.params) :: Plug.Conn.t
  def upsert(conn = %{private: %{parsed_request: parsed_request}}, _) do
    parsed_request.id
    |> ThreadSubscriptionService.upsert(parsed_request.attrs,
                                        parsed_request.opts)
    |> case do
      {:ok, thread_subscription} ->
        conn |> render("show.json", thread_subscription: thread_subscription)
      {:error, changeset} ->
        unprocessable_entity(conn, changeset)
    end
  end
end
