defmodule SystemdWatcher.GenServer do
  use GenServer

  def start_link(name, options \\ %{timeout: 1}) do
    init_state = options |> Map.merge(%{pids: %{}})
    GenServer.start_link(__MODULE__, init_state, name: name)
  end

  def add_pid(name, pid) do
    GenServer.cast(name, {:add_pid, pid})
  end

  def get_pid(name, pid) do
    GenServer.call(name, {:get_pid, pid})
  end

  def show_pids(name) do
    GenServer.call(name, {:show_pids})
  end

  def handle_cast({:add_pid, pid}, state) do
    with nil <- state[:pids][pid] do
      new_pids = state[:pids]
                 |> Map.merge(%{pid => %{mhs: 0, time: System.monotonic_time}})

      {:noreply, state |> Map.merge(%{pids: new_pids})}
    else
      _ -> {:noreply, state}
    end
  end

  defp too_old(time, state) do
    System.monotonic_time
    |> Kernel.-(time)
    |> Kernel./(1_000_000_000)
    |> Kernel.>(state[:timeout])
  end

  def handle_call({:show_pids}, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:get_pid, pid}, _from, state) do
    with nil <- state[:pids][pid] do
      {:reply, :not_found, state}
    else
      %{mhs: mhs, time: time} ->
        if time |> too_old(state) do
          {:reply, :not_found, state}
        else
          {:reply, mhs, state}
        end
    end

  end
end
