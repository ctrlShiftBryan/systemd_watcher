defmodule SystemdWatcher.GenServer do
  use GenServer

  def start_link(name, options \\ %{timeout: 30}) do
    init_state = options |> Map.merge(%{pids: %{}})
    GenServer.start_link(__MODULE__, init_state, name: name)
  end

  def add_pid(name, pid) do
    GenServer.cast(name, {:add_pid, pid})
  end

  def get_pid(name, pid) do
    GenServer.call(name, {:get_pid, pid})
  end

  def handle_cast({:add_pid, pid}, state) do
    with nil <- state[:pids][pid] do
      {:noreply, state |> Map.merge(%{pids: %{pid => %{mhs: 0, time: System.monotonic_time}}})}
    else
      _ -> {:noreply, state}
    end
  end

  defp too_old(time, state) do
    System.monotonic_time |> Kernel.-(time) |> Kernel./(1_000_000_000) |> Kernel.>(state[:timeout])
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
