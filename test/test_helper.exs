{:ok, _} = Application.ensure_all_started(:ex_machina)

System.put_env("SLACK_TOKEN_ENCRYPTION_KEY", String.duplicate("x", 32))
System.put_env("SLACK_CLIENT_ID", String.duplicate("x", 8) <> "." <> String.duplicate("x", 16))
System.put_env("SLACK_CLIENT_SECRET", String.duplicate("x", 32))
System.put_env("REDIRECT_URI", "http://localhost:4200")

if System.get_env("HEROKU_TEST_RUN_ID") do
  ExUnit.configure formatters: [Spout, ExUnit.CLIFormatter]
else
  ExUnit.configure formatters: [ExUnit.CLIFormatter, ExUnitNotifier]
end

ExUnit.start

Ecto.Adapters.SQL.Sandbox.mode(CanvasAPI.Repo, :manual)
