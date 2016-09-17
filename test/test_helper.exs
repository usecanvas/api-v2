{:ok, _} = Application.ensure_all_started(:ex_machina)

System.put_env("SLACK_TOKEN_ENCRYPTION_KEY", String.duplicate("x", 32))

ExUnit.start

Ecto.Adapters.SQL.Sandbox.mode(CanvasAPI.Repo, :manual)
