defmodule SystemdWatcher.TestDiContainer do
  defstruct [ commands: SystemdWatcher.Commands ]
end

defmodule SystemdWatcherTest do
  use ExUnit.Case
  doctest SystemdWatcher
  import Double
  require IEx

  @input  "Jul 12 20:09:37 mine ethminer[32294]:   m  20:09:37|ethminer  Mining on PoWhash #1029edbe : 31.46MH/s [A0+0:R0+0:F0]"
  @input2 "Jul 12 20:09:37 mine ethmine[32294]:   m  20:09:37|ethminer  Mining on PoWhash #1029edbe : 31.46MH/s [A0+0:R0+0:F0]"

  @input3 """
    Jul 12 20:09:37 mine ethminer[0]:   m  20:09:37|ethminer  Mining on PoWhash #1029edbe : 31.46MH/s [A0+0:R0+0:F0]
    Jul 12 20:09:38 mine ethminer[1]:   m  20:09:38|ethminer  Mining on PoWhash #1029edbe : 31.46MH/s [A0+0:R0+0:F0]
    Jul 12 20:09:38 mine ethminer[2]:   m  20:09:38|ethminer  Mining on PoWhash #1029edbe : 31.46MH/s [A0+0:R0+0:F0]
    Jul 12 20:09:38 mine ethminer[3]:   m  20:09:38|ethminer  Mining on PoWhash #1029edbe : 31.46MH/s [A0+0:R0+0:F0]
    Jul 12 20:09:38 mine ethminer[4]:   m  20:09:38|ethminer  Mining on PoWhash #1029edbe : 31.46MH/s [A0+0:R0+0:F0]
    Jul 12 20:09:38 mine ethminer[5]:   m  20:09:38|ethminer  Mining on PoWhash #1029edbe : 31.46MH/s [A0+0:R0+0:F0]
    Jul 12 20:09:39 mine ethminer[5]:   m  20:09:39|ethminer  Mining on PoWhash #1029edbe : 31.46MH/s [A0+0:R0+0:F0]
    Jul 12 20:09:39 mine ethminer[5]:   m  20:09:39|ethminer  Mining on PoWhash #1029edbe : 31.46MH/s [A0+0:R0+0:F0]
    Jul 12 20:09:39 mine ethminer[5]:   m  20:09:39|ethminer  Mining on PoWhash #1029edbe : 26.21MH/s [A0+0:R0+0:F0]
    """

  @input4 """
    Jul 12 20:09:37 mine ethminer[0]:   m  20:09:37|ethminer  Mining on PoWhash #1029edbe : 31.46MH/s [A0+0:R0+0:F0]
    Jul 12 20:09:38 mine ethminer[1]:   m  20:09:38|ethminer  Mining on PoWhash #1029edbe : 31.46MH/s [A0+0:R0+0:F0]
    Jul 12 20:09:38 mine ethminer[2]:   m  20:09:38|ethminer  Mining on PoWhash #1029edbe : 31.46MH/s [A0+0:R0+0:F0]
    Jul 12 20:09:38 mine ethminer[3]:   m  20:09:38|ethminer  Mining on PoWhash #1029edbe : 31.46MH/s [A0+0:R0+0:F0]
    Jul 12 20:09:38 mine ethminer[5]:   m  20:09:38|ethminer  Mining on PoWhash #1029edbe : 31.46MH/s [A0+0:R0+0:F0]
    Jul 12 20:09:39 mine ethminer[5]:   m  20:09:39|ethminer  Mining on PoWhash #1029edbe : 31.46MH/s [A0+0:R0+0:F0]
    Jul 12 20:09:39 mine ethminer[5]:   m  20:09:39|ethminer  Mining on PoWhash #1029edbe : 31.46MH/s [A0+0:R0+0:F0]
    Jul 12 20:09:39 mine ethminer[5]:   m  20:09:39|ethminer  Mining on PoWhash #1029edbe : 26.21MH/s [A0+0:R0+0:F0]
    """

  @input5 "-- No entries --"

  describe "The application" do

    test "no entries" do
      assert SystemdWatcher.get_info(@input5) == :not_found
    end

    test "get pids" do
      assert SystemdWatcher.get_info(@input) == {:ok, "32294",31.46}
    end

    test "not found" do
      assert SystemdWatcher.get_info(@input2) == :not_found
    end

    test "get all pids" do
      assert SystemdWatcher.get_all_pids(@input3) == ["0","1","2","3","4","5"]
    end

    test "get_log" do
      stub = SystemdWatcher.Commands
            |> double
            |> allow(:get_log, fn() -> @input3 end)
            |> allow(:get_log, fn() -> @input4 end)

      container = %SystemdWatcher.DiContainer{commands: stub}
      assert SystemdWatcher.get_log(container) == @input3
      assert SystemdWatcher.get_log(container) == @input4
    end

    test "start app mhs" do
      stub = SystemdWatcher.Commands
      |> double
      |> allow(:get_log, fn() -> @input4 end)

      container = %SystemdWatcher.DiContainer{commands: stub}
      {status, _} = SystemdWatcher.start([], container)


      assert status = :ok

      :timer.sleep 1_000
      result = SystemdWatcher.GenServer.show_pids(:my_pids)
      %{pids: pids} = result
      expected = [31.46, 31.46, 31.46, 31.46, 26.21]
      assert  pids |> Map.values |> Enum.map(fn(%{mhs: mhs}) -> mhs end) == expected

    end

    test "start app" do
      stub = SystemdWatcher.Commands
      |> double
      |> allow(:get_log, fn() -> @input3 end)
      |> allow(:get_log, fn() -> @input4 end)

      container = %SystemdWatcher.DiContainer{commands: stub}
      {status, _} = SystemdWatcher.start([], container)


      assert status = :ok

      :timer.sleep 3_000
      result = SystemdWatcher.GenServer.show_pids(:my_pids)
      %{pids: pids} = result
      assert  pids |> Map.keys() == ["0","1","2","3","4","5"]

      :timer.sleep 5_000

      result = SystemdWatcher.GenServer.show_pids(:my_pids)
      %{pids: pids} = result
      assert  pids |> Map.keys() == ["0","1","2","3","5"]
    end

    test "no pids" do
      stub = SystemdWatcher.Commands
      |> double
      |> allow(:get_log, fn() -> @input5 end)

      container = %SystemdWatcher.DiContainer{commands: stub}
      {status, _} = SystemdWatcher.start([], container)


      assert status = :ok

      :timer.sleep 3_000
      result = SystemdWatcher.GenServer.show_pids(:my_pids)
      %{pids: pids} = result
      assert  pids |> Map.keys() == []
    end
    # test "start app again" do
    #   {status, _} = SystemdWatcher.start([],[])
    #   assert status = :ok
    # end
  end
end
