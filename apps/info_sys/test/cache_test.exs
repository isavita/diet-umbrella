defmodule InfoSys.CacheTest do
  use ExUnit.Case, async: true

  alias InfoSys.Cache

  @moduletag clear_interval: 10

  setup %{test: name, clear_interval: clear_interval} do
    {:ok, pid} = Cache.start_link(name: name, interval: clear_interval)
    {:ok, name: name, pid: pid}
  end

  test "key value pairs can be put and fetched from cache", %{name: name} do
    assert Cache.put(name, :key1, "value1") == :ok
    assert Cache.put(name, :key2, "value2") == :ok

    assert Cache.fetch(name, :key1) == {:ok, "value1"}
    assert Cache.fetch(name, :key2) == {:ok, "value2"}
  end

  test "unfound entry returns error", %{name: name} do
    assert Cache.fetch(name, :noexist) == :error
  end

  test "clear all entries after clear_interval", %{name: name} do
    assert Cache.put(name, :key1, 42) == :ok
    assert Cache.fetch(name, :key1) == {:ok, 42}
    assert eventually(fn -> Cache.fetch(name, :key1) == :error end)
  end

  @tag clear_interval: 60_000
  test "values are cleaned up on exit", %{name: name, pid: pid} do
    assert Cache.put(name, :key1, 42) == :ok
    assert Cache.fetch(name, :key1) == {:ok, 42}
    assert_shutdown(pid)
    {:ok, _cache} = Cache.start_link(name: name)
    assert Cache.fetch(name, :key1) == :error
  end

  defp assert_shutdown(pid) do
    ref = Process.monitor(pid)
    Process.unlink(pid)
    Process.exit(pid, :kill)

    assert_receive {:DOWN, ^ref, :process, ^pid, :killed}
  end

  defp eventually(fun) do
    if fun.() do
      true
    else
      Process.sleep(10)
      eventually(fun)
    end
  end
end
