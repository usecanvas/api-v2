defmodule CanvasAPI.Base62UUIDFieldTest do
  use ExUnit.Case, async: true

  alias CanvasAPI.Base62UUIDField

  test ".type is a string" do
    assert Base62UUIDField.type == :string
  end

  test ".cast casts to a string" do
    assert Base62UUIDField.cast(1) == {:ok, "1"}
  end

  test ".dump dumps the value" do
    assert Base62UUIDField.dump(1) == {:ok, 1}
  end

  test ".load loads the value" do
    assert Base62UUIDField.load(1) == {:ok, 1}
  end

  test ".autogenerate generates a base 62 UUID" do
    assert String.length(Base62UUIDField.autogenerate) == 22
  end
end
