defmodule SystemdWatcher.Runner do
  def start do
    do_it()
  end

  def do_it do
    :timer.sleep(10)
    do_it()
  end
end
