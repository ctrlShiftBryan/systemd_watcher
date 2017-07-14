defmodule SystemdWatcher.Commands do
  def get_log do
    """
    Jul 12 20:09:37 mine ethminer[32294]:   m  20:09:37|ethminer  Mining on PoWhash #1029edbe : 31.46MH/s [A0+0:R0+0:F0]
    Jul 12 20:09:38 mine ethminer[32294]:   m  20:09:38|ethminer  Mining on PoWhash #1029edbe : 31.46MH/s [A0+0:R0+0:F0]
    Jul 12 20:09:38 mine ethminer[32295]:   m  20:09:38|ethminer  Mining on PoWhash #1029edbe : 31.46MH/s [A0+0:R0+0:F0]
    Jul 12 20:09:38 mine ethminer[32295]:   m  20:09:38|ethminer  Mining on PoWhash #1029edbe : 31.46MH/s [A0+0:R0+0:F0]
    Jul 12 20:09:38 mine ethminer[32294]:   m  20:09:38|ethminer  Mining on PoWhash #1029edbe : 31.46MH/s [A0+0:R0+0:F0]
    Jul 12 20:09:38 mine ethminer[32294]:   m  20:09:38|ethminer  Mining on PoWhash #1029edbe : 31.46MH/s [A0+0:R0+0:F0]
    Jul 12 20:09:39 mine ethminer[32294]:   m  20:09:39|ethminer  Mining on PoWhash #1029edbe : 31.46MH/s [A0+0:R0+0:F0]
    Jul 12 20:09:39 mine ethminer[32294]:   m  20:09:39|ethminer  Mining on PoWhash #1029edbe : 31.46MH/s [A0+0:R0+0:F0]
    Jul 12 20:09:39 mine ethminer[32294]:   m  20:09:39|ethminer  Mining on PoWhash #1029edbe : 26.21MH/s [A0+0:R0+0:F0]
    """
  end
end
