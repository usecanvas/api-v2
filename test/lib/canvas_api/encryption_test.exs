defmodule CanvasAPI.EncryptionTest do
  use ExUnit.Case, async: true

  import CanvasAPI.Encryption

  test ".encrypt encrypts a string" do
    assert encrypt("foo") !== "foo"
  end

  test ".decrypt decrypts a string" do
    assert encrypt("foo") |> decrypt == "foo"
  end
end
