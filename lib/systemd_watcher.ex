defmodule SystemdWatcher do
  use Application
  alias SystemdWatcher.GenServer

  require IEx
  def start(_type, args) do
    IEx.pry
    IO.puts "starting...."
    import Supervisor.Spec

    children = [
      supervisor(Task.Supervisor, [[name: SystemdWatcher.TaskSupervisor]])
    ]
    opts = [strategy: :one_for_one, name: SystemdWatcher.Supervisor]
    result = Supervisor.start_link(children, opts)

    Task.Supervisor.start_child(SystemdWatcher.TaskSupervisor, fn ->
      recurse()
    end)

    SystemdWatcher.GenServer.start_link(:my_pids)
    result
  end

  def recurse do
    check_log()
    :timer.sleep 10_000
    recurse()
  end

  def check_log do
    for line <-  get_log() |> String.split("\n") do
      with {:ok, pid, _mhs} <- line |> get_info do
        GenServer.add_pid(:my_pids, pid)
      end
    end
  end

  def get_log(systemd \\ SystemdWatcher.Commands) do
    systemd.get_log()
  end

  def parse_log(text) do
    %{text: text}
  end

  @pid_regex ~r/(?<=ethminer\[)(.+)(?=\]:)/

  def get_all_pids(input) do
    @pid_regex |> Regex.scan(input) |> fix_nil |> List.flatten |> Enum.uniq
  end


  def get_info(input) do
    with x when x in ["",nil]<- @pid_regex
                                |> Regex.run(input)
                                |> fix_nil
                                |> List.flatten
                                |> Enum.at(0)
    do
      :not_found
    else
      pid ->
        with {m, _} <- ~r/(?<=\ \:\ )(.+)(?=MH\/s)/
                      |> Regex.run(input)
                      |> fix_nil
                      |> List.flatten
                      |> Enum.at(0)
                      |> Float.parse do
          {:ok, pid, m}
        else
          _ -> {:ok, pid, 0.0}
        end
    end
  end

  defp fix_nil(nil), do: []
  defp fix_nil(not_nil), do: not_nil
end
