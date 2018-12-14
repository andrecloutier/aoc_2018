defmodule Mix.Tasks.Fourteen do
  use Mix.Task

  def run(_args) do
    input = 846021
    initial_socres = %{0 => 3, 1 => 7}
    initial_positions = [0,1]

    stop_at_len = input + 10
    final_scores = build_scores(initial_socres, initial_positions, 2, stop_at_len)
    solution1 =
      (input..stop_at_len)
      |> Enum.map(fn n -> Map.get(final_scores,n) end)
      |> Enum.join
    IO.puts("Part 1 answer: #{solution1}")

    solution2 = solve_part2(initial_socres, initial_positions, 2, Integer.digits(input))
    IO.puts("Part 2 answer: #{solution2}")
  end

  defp solve_part2(scores, positions, current_length, search) do
    solution_found = if (search |> Stream.with_index(current_length-7) |> Enum.all?(fn {d,idx} -> Map.get(scores,idx) == d end)), do: current_length-7, else: nil
    solution_found2 = if (search |> Stream.with_index(current_length-8) |> Enum.all?(fn {d,idx} -> Map.get(scores,idx) == d end)), do: current_length-8, else: nil

    if solution_found != nil || solution_found2 != nil do
      solution_found || solution_found2
    else
      current_scores = positions |> Enum.map(fn pos -> Map.get(scores, pos) end)

      recepe_score = current_scores |> Enum.sum()

      digits = if recepe_score >= 10, do: [1, rem(recepe_score, 10)], else: [recepe_score]

      {new_scores, new_length} =
        digits
        |> Enum.reduce({scores, current_length}, fn d,{s,cl} -> {Map.put(s,cl,d), cl+1} end)

      new_positions =
        positions
        |> Enum.zip(current_scores)
        |> Enum.map(&Tuple.to_list/1)
        |> Enum.map(&Enum.sum/1)
        |> Enum.map(fn n -> rem(n+1, new_length) end)

      solve_part2(new_scores, new_positions, new_length, search)
    end
  end

  defp build_scores(scores, _positions, current_length, max_length) when current_length >= max_length do
    scores
  end

  defp build_scores(scores, positions, current_length, max_length) do
    current_scores = positions |> Enum.map(fn pos -> Map.get(scores, pos) end)

    recepe_score = current_scores |> Enum.sum()

    digits = if recepe_score >= 10, do: [1, rem(recepe_score, 10)], else: [recepe_score]

    {new_scores, new_length} =
      digits
      |> Enum.reduce({scores, current_length}, fn d,{s,cl} -> {Map.put(s,cl,d), cl+1} end)

    new_positions =
      positions
      |> Enum.zip(current_scores)
      |> Enum.map(&Tuple.to_list/1)
      |> Enum.map(&Enum.sum/1)
      |> Enum.map(fn n -> rem(n+1, new_length) end)

    build_scores(new_scores, new_positions, new_length, max_length)
  end
end
