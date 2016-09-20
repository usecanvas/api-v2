{:ok, _} = Application.ensure_all_started(:ex_machina)

System.put_env("SLACK_TOKEN_ENCRYPTION_KEY", String.duplicate("x", 32))
System.put_env("SLACK_CLIENT_ID", String.duplicate("x", 8) <> "." <> String.duplicate("x", 16))
System.put_env("SLACK_CLIENT_SECRET", String.duplicate("x", 32))
System.put_env("REDIRECT_URI", "http://localhost:4200")

ExUnit.start

Ecto.Adapters.SQL.Sandbox.mode(CanvasAPI.Repo, :manual)
