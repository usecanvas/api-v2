defmodule CanvasAPI.Encryption do
  @moduledoc """
  Encrypts and decrypts binary strings.
  """

  @doc """
  Decrypt a string into plaintext.
  """
  @spec decrypt(String.t) :: String.t
  def decrypt(ciphertext) do
    <<iv::binary-16, ciphertext::binary>> = ciphertext |> Base.decode64!
    state = :crypto.stream_init(:aes_ctr, key, iv)

    {_state, plaintext} = :crypto.stream_decrypt(state, ciphertext)
    plaintext
  end

  @doc """
  Encrypt a string into ciphertext.
  """
  @spec encrypt(String.t) :: String.t
  def encrypt(plaintext) do
    iv = :crypto.strong_rand_bytes(16)
    state = :crypto.stream_init(:aes_ctr, key, iv)

    {_state, ciphertext} = :crypto.stream_encrypt(state, plaintext)
    iv <> ciphertext |> Base.encode64
  end

  # Get the encryption/decryption key
  @spec key :: String.t
  defp key, do: System.get_env("SLACK_TOKEN_ENCRYPTION_KEY")
end
