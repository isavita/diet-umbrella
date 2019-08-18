defmodule InfoSysTest do
  use ExUnit.Case

  alias InfoSys.Result

  defmodule TestBackend do
    def name, do: "Wolfram"

    def compute("result", _opts) do
      [%Result{backend: __MODULE__, text: "result"}]
    end

    def compute("none", _opts), do: []

    def compute("timeout", _opts), do: Process.sleep(:infinity)

    def compute("boom", _opts), do: raise("boom")
  end

  test "compute/2 with backend result" do
    assert [%Result{backend: TestBackend, text: "result"}] =
             InfoSys.compute("result", backends: [TestBackend])
  end

  test "compute/2 without backend result" do
    assert InfoSys.compute("none", backends: [TestBackend]) == []
  end

  test "compute/2 with timeout returens no result" do
    assert InfoSys.compute("timeout", backends: [TestBackend], timeout: 10) == []
  end

  @tag :capture_log
  test "compute/2 discards backend errors" do
    assert InfoSys.compute("boom", backends: [TestBackend]) == []
  end
end
