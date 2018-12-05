defmodule Mix.Tasks.Four do
  use Mix.Task

  defmodule State do
    # guard id to list of mins
    defstruct guard_to_sleep: %{}, last_guard: nil, sleep_start_time: nil
  end

  def run(_args) do
    state =
      File.stream!("inputs/4.txt")
      |> Enum.map(&parse_input/1)
      |> Enum.sort(fn [time_a, _],[time_b, _]  -> NaiveDateTime.compare(time_a, time_b) == :lt end)
      |> Enum.reduce(%State{}, &process_line/2)

    {id, mins} =
      state.guard_to_sleep
      |> Enum.max_by(fn {_, mins} -> Enum.count(mins) end)

    {most_frequent_min, _count} =
      mins
      |> Enum.reduce(%{}, fn minute, agg -> put_in(agg[minute], (agg[minute] || 0) + 1) end)
      |> Enum.max_by(fn {_k,v} -> v end)

    IO.puts("Part 1 answer: #{id * most_frequent_min}")

    {{p2_id, p2_min}, _count} =
      state.guard_to_sleep
      |> Enum.map(fn {id, minutes} -> Enum.map(minutes, fn m -> {id, m} end) end)
      |> Enum.concat()
      |> Enum.reduce(%{}, fn t, agg -> put_in(agg[t], (agg[t] || 0) + 1) end)
      |> Enum.max_by(fn {_k,v} -> v end)

    IO.puts("Part 2 answer: #{p2_id * p2_min}")
  end

  defp process_line([_time, [:guard, guard_id]], %State{sleep_start_time: nil} = state) do
    %State{ state |
      last_guard: guard_id
    }
  end

  defp process_line([current_time, [:sleep, _]], state) do
    %State{ state |
      sleep_start_time: current_time
    }
  end

  defp process_line([current_time, [:wake, _]], state) do
    mins_between = increment_minute(current_time, state.sleep_start_time)
    current_minutes =
      state.guard_to_sleep
      |> Map.get(state.last_guard, [])
      |> Enum.concat(mins_between)

    %State{state |
      guard_to_sleep: state.guard_to_sleep |> Map.put(state.last_guard, current_minutes),
      sleep_start_time: nil
    }
  end

  defp increment_minute(time, time), do: []
  defp increment_minute(end_time, current_time) do
    [current_time.minute | increment_minute(end_time, NaiveDateTime.add(current_time, 1))]
  end

  defp parse_input(line) do
    #[1518-06-02 23:58] Guard #179 begins shift
    #[1518-09-18 00:43] wakes up
    #[1518-06-06 00:10] falls asleep
    parts = line |> String.split()
    [year, month, date] = parts |> Enum.at(0) |> String.trim("[") |> String.split("-") |> Enum.map(&String.to_integer/1)
    [hour, minute] = parts |> Enum.at(1) |> String.trim("]") |> String.split(":") |> Enum.map(&String.to_integer/1)

    action =
      case parts |> Enum.at(2) do
        "Guard" -> [:guard, Enum.at(parts, 3) |> String.trim("#") |> String.to_integer()]
        "wakes" -> [:wake, nil]
        "falls" -> [:sleep, nil]
        e -> raise "unknown #{e}"
      end
    {:ok, dt} = NaiveDateTime.new(year, month, date, hour, minute, 0)
    [dt, action]
  end
end
