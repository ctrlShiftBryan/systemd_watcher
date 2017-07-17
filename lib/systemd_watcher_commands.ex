defmodule SystemdWatcher.Commands do
  def get_log do
    {log, 0} = System.cmd("journalctl", ["--since=1 second ago"])
    log
  end
end
