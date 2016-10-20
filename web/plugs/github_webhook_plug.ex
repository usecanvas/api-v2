defmodule CanvasAPI.GitHubWebhookPlug do
  @moduledoc """
  Verifies a GitHub webhook callback by validating that the signature matches
  the body.
  """

  @key System.get_env("GITHUB_VERIFICATION_TOKEN")

  import Plug.Conn

  @behaviour Plug

  def init(opts), do: opts

  def call(conn, opts) do
    mount = opts[:mount]
    case conn.path_info do
      ^mount -> verify_request(conn, opts)
      _ -> conn
    end
  end

  defp verify_request(conn, _opts) do
    {:ok, body, _} = read_body(conn)

    with ["sha1=" <> signature] <- get_req_header(conn, "x-hub-signature"),
         signature <- Base.decode16!(signature, case: :lower),
         hmac = :crypto.hmac(:sha, @key, body),
         ^signature <- hmac do
      conn = Plug.Conn.fetch_query_params(conn)
      params = Map.merge(conn.query_params, Poison.decode!(body))
      # CanvasAPI.GitHubTrackback.delay_add(params, params["team.id"])
      CanvasAPI.GitHubTrackback.add(params, params["team.id"])
      conn |> send_resp(:ok, "") |> halt
    else
      _ ->
        conn
        |> put_resp_content_type("text/plain")
        |> send_resp(401, "Not Authorized")
        |> halt
    end
  end
end
