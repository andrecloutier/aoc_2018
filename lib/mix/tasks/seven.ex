defmodule Mix.Tasks.Seven do
  use Mix.Task

  def run(_args) do
    dependencies =
      File.stream!("inputs/7.txt")
      |> Enum.map(fn line ->
        parts =
          line
          |> String.trim
          |> String.split(" ")

        [7,1]
        |> Enum.map(fn pos -> Enum.at(parts, pos) end)
      end)
      |> Enum.reduce(%{}, fn [k,v], agg -> put_in(agg[k], MapSet.put(agg[k] || MapSet.new, v)) end)

    unique_chars =
      dependencies
      |> Map.to_list()
      |> Enum.map(fn {k,v} -> MapSet.put(v, k) end)
      |> Enum.reduce(MapSet.new, &MapSet.union/2)
      |> MapSet.to_list()
      |> Enum.sort()

    first_soln = solve_it(unique_chars, MapSet.new, dependencies)
    IO.puts("Part 1 answer: #{first_soln}")

    workers = (1..5) |> Enum.map(fn n -> {n, [:free, "", 0]} end) |> Map.new
    second_soln = solve_it_2(unique_chars, MapSet.new, dependencies, 0, workers)
    IO.puts("Part 2 answer: #{second_soln}")
  end

  defp solve_it([], _, _), do: []
  defp solve_it(unique_chars, used_chars, dependencies) do
    char_to_use =
      unique_chars
      |> Enum.find(fn c ->
        !Map.has_key?(dependencies, c) or MapSet.subset?(dependencies[c], used_chars)
      end)

    next_chars = Enum.reject(unique_chars, fn c -> c == char_to_use end)
    [char_to_use | solve_it(next_chars, MapSet.put(used_chars, char_to_use), dependencies)]
  end

  defp solve_it_2([], _, _, _, workers) do
    workers
    |> Map.to_list()
    |> Enum.map(fn {_id, [_status, _letter, done_ts]} -> done_ts end)
    |> Enum.max
  end

  defp solve_it_2(unique_chars, used_chars, dependencies, time, workers) do
    # Complete workers
    completed_workers =
      workers
      |> Map.to_list()
      |> Enum.filter(fn {_id, [state, _letter, done_ts]} -> state == :working && done_ts <= time end)

    new_used_chars =
      completed_workers
      |> Enum.reduce(
         used_chars,
         fn {_id, [_state, letter, _done_ts]}, agg -> MapSet.put(agg, letter) end
       )

    new_workers =
      completed_workers
      |> Enum.map(fn {id, _} -> id end)
      |> Enum.reduce(workers, fn id, agg -> Map.put(agg, id, [:free, "", 0]) end)

    # Find work

    char_to_use =
      unique_chars
      |> Enum.find(fn c ->
        !Map.has_key?(dependencies, c) or MapSet.subset?(dependencies[c], new_used_chars)
      end)

    free_worker =
      new_workers
      |> Map.to_list()
      |> Enum.find(fn {_id, [state, _letter, _done_ts]} -> state == :free end)

    if free_worker != nil && char_to_use != nil do
      # Put the worker to work
      {id, _} = free_worker

      next_chars = Enum.reject(unique_chars, fn c -> c == char_to_use end)
      letter_sleep = (char_to_use |> String.to_charlist |> hd) - 64
      next_workers = new_workers |> Map.put(id, [:working, char_to_use, time + 60 + letter_sleep])

      # IO.puts("At time #{time} assigning #{char_to_use} to #{id} until #{time + 60 + letter_sleep}")
      solve_it_2(next_chars, new_used_chars, dependencies, time, next_workers)
    else
      # Nothing to do - advance to next completed piece of work
      next_time =
        new_workers
        |> Map.to_list()
        |> Enum.filter(fn {_id, [state, _letter, _done_ts]} -> state == :working end)
        |> Enum.map(fn {_id, [_state, _letter, done_ts]} -> done_ts end)
        |> Enum.min()

      solve_it_2(unique_chars, new_used_chars, dependencies, next_time, new_workers)
    end

  end
end