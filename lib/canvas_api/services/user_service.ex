defmodule CanvasAPI.UserService do
  use CanvasAPI.Web, :service
  alias CanvasAPI.User

  def insert(params, opts) do
    %User{}
    |> User.changeset(params)
    |> put_assoc(:account, opts[:account])
    |> put_assoc(:team, opts[:team])
    |> Repo.insert
  end
end
