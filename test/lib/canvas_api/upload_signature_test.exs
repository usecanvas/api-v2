defmodule CanvasAPI.UploadSignatureTest do
  use ExUnit.Case, async: true

  alias CanvasAPI.UploadSignature

  test ".generate/0 generates a signature struct" do
    sig = UploadSignature.generate
    assert sig.__struct__ == UploadSignature
    assert sig.upload_url == "https://canvas-files-prod.s3.amazonaws.com"
    assert sig.id == "u"
  end
end
