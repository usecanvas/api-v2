defmodule CanvasAPI.EncryptedFieldTest do
  use ExUnit.Case, async: true

  alias CanvasAPI.{EncryptedField, Encryption}

  test ".type is a string" do
    assert EncryptedField.type == :string
  end

  test ".cast casts to a string" do
    assert EncryptedField.cast(1) == {:ok, "1"}
  end

  test ".cast handles nil" do
    assert EncryptedField.cast(nil) == {:ok, nil}
  end

  test ".dump enrypts the value" do
    assert EncryptedField.dump("1") |> elem(1) |> Encryption.decrypt == "1"
  end

  test ".dump handles nil" do
    assert EncryptedField.dump(nil) == {:ok, nil}
  end

  test ".load decrypts the value" do
    value = Encryption.encrypt("test")
    assert EncryptedField.load(value) == {:ok, "test"}
  end

  test ".load handles nil" do
    assert EncryptedField.load(nil) == {:ok, nil}
  end
end
