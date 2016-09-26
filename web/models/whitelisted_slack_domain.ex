defmodule CanvasAPI.WhitelistedSlackDomain do
  use CanvasAPI.Web, :model

  schema "whitelisted_slack_domains" do
    field :domain, :string

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:domain])
    |> validate_required([:domain])
    |> unique_constraint(:domain)
  end
end
