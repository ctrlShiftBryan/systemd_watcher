defmodule SystemdWatcher do
  def sample do
    input = """
    Jul 12 20:09:37 mine ethminer[32294]:   m  20:09:37|ethminer  Mining on PoWhash #1029edbe : 31.46MH/s [A0+0:R0+0:F0]
    Jul 12 20:09:38 mine ethminer[32294]:   m  20:09:38|ethminer  Mining on PoWhash #1029edbe : 31.46MH/s [A0+0:R0+0:F0]
    Jul 12 20:09:38 mine ethminer[32294]:   m  20:09:38|ethminer  Mining on PoWhash #1029edbe : 31.46MH/s [A0+0:R0+0:F0]
    Jul 12 20:09:38 mine ethminer[32294]:   m  20:09:38|ethminer  Mining on PoWhash #1029edbe : 31.46MH/s [A0+0:R0+0:F0]
    Jul 12 20:09:38 mine ethminer[32294]:   m  20:09:38|ethminer  Mining on PoWhash #1029edbe : 31.46MH/s [A0+0:R0+0:F0]
    Jul 12 20:09:38 mine ethminer[32294]:   m  20:09:38|ethminer  Mining on PoWhash #1029edbe : 31.46MH/s [A0+0:R0+0:F0]
    Jul 12 20:09:39 mine ethminer[32294]:   m  20:09:39|ethminer  Mining on PoWhash #1029edbe : 31.46MH/s [A0+0:R0+0:F0]
    Jul 12 20:09:39 mine ethminer[32294]:   m  20:09:39|ethminer  Mining on PoWhash #1029edbe : 31.46MH/s [A0+0:R0+0:F0]
    Jul 12 20:09:39 mine ethminer[32294]:   m  20:09:39|ethminer  Mining on PoWhash #1029edbe : 26.21MH/s [A0+0:R0+0:F0]
    """
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
