defmodule SystemdWatcher.GenServer do
  use GenServer

  @timeout Application.get_env(:systemd_watcher, :timeout)

  def start_link(name, options \\ %{timeout: @timeout}) do
    init_state = options |> Map.merge(%{pids: %{}})
    GenServer.start_link(__MODULE__, init_state, name: name)
  end

  def add_pid(name, {pid, mhs}) do
    GenServer.cast(name, {:add_pid, {pid, mhs}})
  end

  def get_pid(name, pid) do
    GenServer.call(name, {:get_pid, pid})
  end

  def show_pids(name) do
    GenServer.call(name, {:show_pids})
  end

  def handle_cast({:add_pid, {pid, mhs}}, state) do
    new_pids = state[:pids]
               |> Map.merge(%{pid => %{mhs: mhs, time: System.monotonic_time}})

    {:noreply, state |> Map.merge(%{pids: new_pids})}
  end

  defp too_old(time, state) do
    System.monotonic_time
    |> Kernel.-(time)
    |> Kernel./(1_000_000_000)
    |> Kernel.>(state[:timeout])
  end
  # %{pids: %{"0" => %{mhs: 0, time: -576460749236712288},
  #           "1" => %{mhs: 0, time: -576460749236653141},
  #           "2" => %{mhs: 0, time: -576460749236602434},
  #           "3" => %{mhs: 0, time: -576460749236552464},
  #           "4" => %{mhs: 0, time: -576460751242852735},
  #           "5" => %{mhs: 0, time: -576460749236351546}}, timeout: 5}
  require IEx
  def purge_state(state) do
    rejects = for {key , %{mhs: _mhs, time: time}}  <- state[:pids] do
      if time |> too_old(state)do
        key
      end
    end |> Enum.reject(fn(x) -> x == nil end)
    pids = state[:pids] |> Map.drop(rejects)
    %{:pids => pids, :timeout => state[:timeout]}
  end

  def handle_call({:show_pids}, _from, state) do
    new_state = state |> purge_state()
    {:reply, new_state, new_state}
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
