defmodule CanvasAPI.EncryptedFieldTest do
  use ExUnit.Case, async: true

  alias CanvasAPI.{EncryptedField, Encryption}

  test ".type is a string" do
    assert EncryptedField.type == :string
  end

  test ".cast casts to a string" do
    assert EncryptedField.cast(1) == {:ok, "1"}
  end

  test ".dump enrypts the value" do
    assert EncryptedField.dump("1") |> elem(1) |> Encryption.decrypt == "1"
  end

  test ".load decrypts the value" do
    value = Encryption.encrypt("test")
    assert EncryptedField.load(value) == {:ok, "test"}
  end
end
