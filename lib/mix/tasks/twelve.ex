defmodule Mix.Tasks.Twelve do
  use Mix.Task

  def run(_args) do
    initial_state =
      File.stream!("inputs/12.txt")
      |> Enum.at(0)
      |> String.trim()
      |> String.split(" ")
      |> Enum.at(2)
      |> String.codepoints()

    mappings =
      File.stream!("inputs/12.txt")
      |> Stream.drop(2)
      |> Enum.map(fn line ->
        #..#. => #
        line
        |> String.split("=>")
        |> Enum.map(&String.trim/1)
        |> List.to_tuple()
      end)
      |> Map.new()

    IO.puts("0 #{Enum.join(initial_state)}")

    part_1_soln = calculate_for(mappings, initial_state, 20)
    IO.puts("Part 1 answer: #{part_1_soln}")

    part_2_soln = calculate_for(mappings, initial_state, 50000000000)
    IO.puts("Part 2 answer: #{part_2_soln}")
  end

  def calculate_for(mappings, initial_state, num_iterations) do
    buffer_size = 3*num_iterations
    buffer = (1..(buffer_size)) |> Enum.map(fn _ -> "." end)

    recurse_over_gens(mappings, (buffer ++ initial_state) ++ buffer, num_iterations)
    |> Enum.with_index(-1 * buffer_size)
    |> Enum.map(fn {c, idx} -> if c == "#", do: idx, else: 0 end)
    |> Enum.sum()
  end

  def recurse_over_gens(_mappings, state, 0), do: state
  def recurse_over_gens(mappings, state, num_gens) do
    {current_set, new_rest} = state |> Enum.split(5)
    new_state = compute_next_gen(mappings, current_set, new_rest)

#    IO.puts("#{21-num_gens} #{Enum.join(new_state) |> String.trim(".")}")

    [".", "."] ++ recurse_over_gens(mappings, new_state, num_gens-1)
  end


  defp compute_next_gen(mappings, [_ | rest_of_current] = current_set, [next_plant | rest]) when length(current_set) == 5 do
    next_char = Map.get(mappings, Enum.join(current_set)) || "."
    [next_char | compute_next_gen(mappings, rest_of_current ++ [next_plant], rest)]
  end

  defp compute_next_gen(_mappings, current_set, []) do
    current_set
  end
end
