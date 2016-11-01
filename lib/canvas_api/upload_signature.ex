defmodule CanvasAPI.UploadSignature do
  @moduledoc """
  A signature used for uploading content to an Amazon S3 bucket.
  """

  @url           "FILE_UPLOAD_URL" |> System.get_env |> URI.parse
  @bucket        @url.host |> String.split(".") |> List.first
  @query         @url.query |> URI.decode_query
  @acl           @query["acl"]
  @max_size      @query |> Map.get("maxSize", "15_000_000") |> String.to_integer
  @access_key_id @url.userinfo |> String.split(":") |> List.first
  @upload_url    "#{@url.scheme}://#{@url.host}"
  @expiration    @query |> Map.get("expiration", "30") |> String.to_integer
  @secret        @url.userinfo |> String.split(":") |> List.last

  defstruct id: @access_key_id,
            policy: "",
            signature: "",
            upload_url: @upload_url

  @type t :: %__MODULE__{
    id: String.t,
    policy: String.t,
    signature: String.t,
    upload_url: String.t
  }

  @doc false
  def json_api_type, do: "upload-signature"

  @doc """
  Generate a new upload signature.
  """
  @spec generate() :: t
  def generate do
    %__MODULE__{
      policy: policy() |> Poison.encode! |> Base.encode64
    }
    |> add_signature
  end

  @spec policy() :: map
  defp policy do
    %{
      expiration: policy_expiration(),
      conditions: [
        %{bucket: @bucket},
        %{acl: @acl},
        ["starts-with", "$key", ""],
        ["starts-with", "$Content-Type", ""],
        ["content-length-range", 0, @max_size]
      ]
    }
  end

  @spec add_signature(t) :: t
  defp add_signature(signature) do
    signature
    |> Map.put(:signature, generate_signature(signature.policy))
  end

  @spec generate_signature(map) :: String.t
  defp generate_signature(policy) do
    :crypto.hmac(:sha, @secret, policy)
    |> Base.encode64
  end

  @spec policy_expiration() :: String.t
  defp policy_expiration do
    DateTime.utc_now
    |> Timex.add(Timex.Duration.from_minutes(@expiration))
    |> DateTime.to_iso8601
  end
end
