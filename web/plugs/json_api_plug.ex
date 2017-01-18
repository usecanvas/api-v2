defmodule CanvasAPI.JSONAPIPlug do
  @moduledoc """
  Transforms a JSON API request into a format more suitable for using internal
  Canvas services
  """

  alias CanvasAPI.Account

  @behaviour Plug

  defstruct id: nil,
            attrs: %{},
            opts: []

  @typedoc """
  A parsed JSON API request.
  """
  @type t :: %__MODULE__{
    id: String.t | nil,
    attrs: %{optional(String.t | atom) => any},
    opts: Keyword.t}

  @spec init(Keyword.t) :: Keyword.t
  def init(opts), do: opts

  @spec call(Plug.Conn.t, Keyword.t) :: Plug.Conn.t
  def call(conn, _opts) do
    conn
    |> Plug.Conn.put_private(:parsed_request, parse_request(conn))
  end

  @spec parse_request(Plug.Conn.t) :: t
  defp parse_request(conn) do
    %__MODULE__{}
    |> put_id(conn.params)
    |> put_attrs(conn.params)
    |> put_rels(conn.params)
    |> put_account(conn.private[:current_account])
    |> put_filter(conn.params)
  end

  @spec put_account(t, Account.t | nil) :: t
  defp put_account(struct, account = %Account{}) do
    struct.opts[:account]
    |> put_in(account)
  end

  defp put_account(struct, _), do: struct

  @spec put_attrs(t, Plug.Conn.params) :: t
  defp put_attrs(struct,
                 %{"data" => %{"attributes" => attrs}}) when is_map(attrs),
    do: %{struct | attrs: attrs}
  defp put_attrs(struct, _), do: struct

  @spec put_filter(t, Plug.Conn.params) :: t
  defp put_filter(struct, %{"filter" => filter}) when is_map(filter),
    do: put_in(struct.opts[:filter], filter)
  defp put_filter(struct, _), do: struct

  @spec put_id(t, Plug.Conn.params) :: t
  defp put_id(struct, %{"id" => id}) when is_binary(id),
    do: %{struct | id: id}
  defp put_id(struct, _), do: struct

  @spec put_rels(t, Plug.Conn.params) :: t
  defp put_rels(struct,
                %{"data" => %{"relationships" => rels}}) when is_map(rels) do
    rels
    |> Enum.reduce(struct, &put_rel/2)
  end
  defp put_rels(struct, _), do: struct

  @spec put_rel({String.t, any}, t) :: t
  defp put_rel({key, %{"data" => %{"id" => id}}}, struct) when is_binary(id),
    do: put_in(struct.attrs["#{key}_id"], id)
  defp put_rel(_, struct), do: struct
end
