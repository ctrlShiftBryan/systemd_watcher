defmodule SystemdWatcherTest do
  use ExUnit.Case
  doctest SystemdWatcher



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

  test "get pids" do
    assert SystemdWatcher.get_info(@input) == {:ok, "32294",31.46}
  end

  test "not found" do
    assert SystemdWatcher.get_info(@input2) == :not_found
  end

  test "get all pids" do
    assert SystemdWatcher.get_all_pids(@input3) == ["0","1","2","3","4","5"]
  end
end
