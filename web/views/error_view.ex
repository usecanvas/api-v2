defmodule CanvasAPI.ErrorView do
  use CanvasAPI.Web, :view

  def render("400.json", assigns) do
    render("error.json", detail: assigns[:detail] || "Bad request")
  end

  def render("401.json", _assigns) do
    render("error.json", detail: "Unauthorized")
  end

  def render("403.json", assigns) do
    render("error.json", detail: assigns[:detail] || "Forbidden")
  end

  def render("404.json", _assigns) do
    render("error.json", detail: "Page not found")
  end

  def render("500.json", _assigns) do
    render("error.json", detail: "Internal server error")
  end

  def render("error.json", %{detail: detail}) do
    %{errors: %{detail: detail}}
  end

  # In case no render clause matches or no
  # template is found, let's render it as 500
  def template_not_found(_template, assigns) do
    render "500.json", assigns
  end
end
