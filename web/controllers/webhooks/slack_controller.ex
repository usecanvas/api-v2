defmodule CanvasAPI.Webhooks.SlackController do
  use CanvasAPI.Web, :controller

  alias CanvasAPI.SlackTrackback

  @token System.get_env("SLACK_VERIFICATION_TOKEN")

  def handle(conn, %{
    "type" => "url_verification",
    "challenge" => challenge,
    "token" => @token}) do
    render(conn, "verify.json", challenge: challenge)
  end

  def handle(conn, %{
    "type" => "event_callback",
    "token" => @token,
    "event" => event,
    "team_id" => team_id}) do
    SlackTrackback.delay_add(event, team_id)
    send_resp(conn, :no_content, "")
  end
end
