defmodule CanvasAPI.OAuth.Slack.CallbackController do
  use CanvasAPI.Web, :controller

  alias CanvasAPI.{Account, Membership, Team}

  @doc """
  Respond to a Slack OAuth callback by creating a new user and team.
  """
  @spec callback(Plug.Conn.t, Plug.Conn.params) :: Plug.Conn.t
  def callback(conn, %{"code" => code, "state" => "identity"}) do
    with {:ok, %{team: team_info, user: user_info, token: token}} <- exchange_code(code),
         {:ok, {_, account}} <- ensure_team_and_account(team_info, user_info, token) do
      conn
      |> fetch_session
      |> put_session(:account_id, account.id)
      |> redirect(external: System.get_env("REDIRECT_ON_LOGIN_URL"))
    else
      {:error, error} ->
        conn |> resp(400, error)
    end
  end

  # Ensure a team/user pair exists.
  @spec ensure_team_and_account(map, map, String.t) :: {:ok, {Team.t, Account.t}}
  defp ensure_team_and_account(team_info, user_info, token) do
    Repo.transaction(fn ->
      with {:ok, team} <- find_or_insert_team(team_info),
           {:ok, account} <- find_or_insert_account(user_info),
           {:ok, _} <- find_or_insert_membership(team, account, token) do
       {team, account}
      else
        error -> Repo.rollback(error)
      end
    end)
  end

  # Exchange an OAuth code for a token, user, and team info.
  @spec exchange_code(String.t) :: {:ok, map} | {:error, any}
  defp exchange_code(code) do
    response =
      Slack.OAuth.access(client_id: System.get_env("SLACK_CLIENT_ID"),
                         client_secret: System.get_env("SLACK_CLIENT_SECRET"),
                         code: code)
    case response do
      {:ok, body} ->
        {:ok,
         %{token: body["access_token"], team: body["team"], user: body["user"]}}
      error ->
        {:error, error}
    end
  end

  # Find or insert a membership for a team/user pair.
  @spec find_or_insert_membership(Team.t, Account.t, String.t) :: {:ok, Membershipo.t} | {:error, any}
  defp find_or_insert_membership(team, account, slack_token) do
    query = from(m in Membership,
                 where: m.account_id == ^account.id,
                 where: m.team_id == ^team.id)

    with nil <- Repo.one(query),
         changeset = %Membership{}
                     |> Membership.changeset(%{identity_token: slack_token})
                     |> Ecto.Changeset.put_assoc(:account, account)
                     |> Ecto.Changeset.put_assoc(:team, team),
         {:ok, membership} <- Repo.insert(changeset) do
      {:ok, membership}
    else
      membership = %Membership{} -> {:ok, membership}
      error -> error
    end
  end

  # Find or insert a team.
  @spec find_or_insert_team(map) :: {:ok, Team.t} | {:error, any}
  defp find_or_insert_team(team_info) do
    team_info =
      team_info
      |> Map.put("slack_id", team_info["id"])
      |> Map.put("image_url", team_info["image_original"])
      |> Map.delete("id")

    query = from(t in Team, where: t.slack_id == ^team_info["slack_id"])

    with nil <- Repo.one(query),
         changeset = Team.changeset(%Team{}, team_info),
         {:ok, team} <- Repo.insert(changeset) do
      {:ok, team}
    else
      team = %Team{} -> {:ok, team}
      error -> error
    end
  end

  # Find or insert a user.
  @spec find_or_insert_account(map) :: {:ok, Account.t} | {:error, any}
  defp find_or_insert_account(user_info) do
    user_info =
      user_info
      |> Map.put("slack_id", user_info["id"])
      |> Map.put("image_url", user_image_url(user_info))
      |> Map.delete("id")

    query = from(a in Account, where: a.slack_id == ^user_info["slack_id"])

    with nil <- Repo.one(query),
         changeset = Account.changeset(%Account{}, user_info),
         {:ok, account} <- Repo.insert(changeset) do
      {:ok, account}
    else
      account = %Account{} -> {:ok, account}
      error -> error
    end
  end

  # Get the image URL from user info.
  @spec user_image_url(map) :: String.t
  defp user_image_url(user_info) do
    String.replace(user_info["image_24"], ~r/_24\.png\z/, "_original.png")
  end
end
