defmodule CanvasAPI.Webhooks.SlackController do
  use CanvasAPI.Web, :controller

  @secret System.get_env("SLACK_CLIENT_SECRET")

  def handle(conn, %{
    "type" => "url_verification",
    "challenge" => challenge,
    "token" => _}) do
    render(conn, "verify.json", challenge: challenge)
  end
end
