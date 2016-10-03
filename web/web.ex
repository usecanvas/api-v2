defmodule CanvasAPI.Web do
  @moduledoc """
  A module that keeps using definitions for controllers,
  views and so on.

  This can be used in your application as:

      use CanvasAPI.Web, :controller
      use CanvasAPI.Web, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below.
  """

  def model do
    quote do
      alias CanvasAPI.Repo

      use Ecto.Schema
      use Calecto.Schema, usec: true

      import Ecto
      import Ecto.Changeset
      import Ecto.Query

      @primary_key {:id, :binary_id, autogenerate: true}
      @foreign_key_type :binary_id
    end
  end

  def controller do
    quote do
      use Phoenix.Controller, namespace: CanvasAPI

      alias CanvasAPI.Repo
      import CanvasAPI.TeamPlug
      import Ecto
      import Ecto.Query
      import Ecto.Changeset

      import CanvasAPI.Router.Helpers
      import CanvasAPI.Gettext
    end
  end

  def view do
    quote do
      use Phoenix.View, root: "web/templates", namespace: CanvasAPI

      # Import convenience functions from controllers
      import Phoenix.Controller,
        only: [get_csrf_token: 0, get_flash: 2, view_module: 1]

      import CanvasAPI.Router.Helpers
      import CanvasAPI.ErrorHelpers
      import CanvasAPI.Gettext
      import CanvasAPI.JSONAPIView
    end
  end

  def router do
    quote do
      use Phoenix.Router
    end
  end

  def channel do
    quote do
      use Phoenix.Channel

      alias CanvasAPI.Repo
      import Ecto
      import Ecto.Query
      import CanvasAPI.Gettext
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
