defmodule InfoSys.WolframTest do
  use ExUnit.Case, async: true

  alias InfoSys.Wolfram

  test "makes request, reports result, then terminates" do
    actual = hd(Wolfram.compute("1+1", []))
    assert actual.text == "2"
  end

  test "no query results reports an empty list" do
    assert Wolfram.compute("none", []) == []
  end
end
