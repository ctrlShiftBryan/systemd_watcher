defmodule SystemdWatcherGenServerTest do
  use ExUnit.Case

  test "gen server can store a pid" do
    SystemdWatcher.GenServer.start_link(:me)
    assert SystemdWatcher.GenServer.add_pid(:me, "123") == :ok
    assert  SystemdWatcher.GenServer.get_pid(:me, "123") == 0
  end

  test "values expire" do
    SystemdWatcher.GenServer.start_link(:me, %{timeout: 1})
    assert SystemdWatcher.GenServer.add_pid(:me, "123") == :ok
    assert  SystemdWatcher.GenServer.get_pid(:me, "123") == 0
    :timer.sleep 1_001
    assert  SystemdWatcher.GenServer.get_pid(:me, "123") == :not_found
  end
end
