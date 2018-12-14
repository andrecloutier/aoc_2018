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

#    IO.puts("0 #{Enum.join(initial_state)}")

    part_1_soln = calculate_for(mappings, initial_state, 20)
    IO.puts("Part 1 answer: #{part_1_soln}")

    # See commented code below used to detect that the result converges over iterations
    two_hundred_soln = calculate_for(mappings, initial_state, 200)
    three_hundred_soln = calculate_for(mappings, initial_state, 300)
    part_2_num_iterations = 50000000000
    part_2_soln = (((part_2_num_iterations - 300)/100) * (three_hundred_soln - two_hundred_soln)) + three_hundred_soln
    IO.puts("Part 2 answer: #{:erlang.float_to_binary(part_2_soln, [decimals: 0])}")
  end

  def calculate_for(mappings, initial_state, num_iterations) do
    buffer_size = 3*num_iterations
    buffer = (1..(buffer_size)) |> Enum.map(fn _ -> "." end)

    recurse_over_gens(mappings, (buffer ++ initial_state) ++ buffer, num_iterations, MapSet.new)
    |> Enum.with_index(-1 * buffer_size)
    |> Enum.map(fn {c, idx} -> if c == "#", do: idx, else: 0 end)
    |> Enum.sum()
  end

  def recurse_over_gens(_mappings, state, 0, _cycle_tracker), do: state
  def recurse_over_gens(mappings, state, num_gens,cycle_tracker) do
    {current_set, new_rest} = state |> Enum.split(5)
    new_state = compute_next_gen(mappings, current_set, new_rest)

    str = ""
#    str = Enum.join(new_state) |> String.trim(".")
#    if MapSet.member?(cycle_tracker, str) do
#      {buffer_size, _} = Enum.split_while(new_state, fn c -> c == "." end)
#      IO.puts "Found loop at #{num_gens} with buflen #{length(buffer_size)} : #{str}"
#    end
#    IO.puts("#{21-num_gens} #{Enum.join(new_state) |> String.trim(".")}")

    [".", "."] ++ recurse_over_gens(mappings, new_state, num_gens-1, MapSet.put(cycle_tracker, str))
  end


  defp compute_next_gen(mappings, [_ | rest_of_current] = current_set, [next_plant | rest]) when length(current_set) == 5 do
    next_char = Map.get(mappings, Enum.join(current_set)) || "."
    [next_char | compute_next_gen(mappings, rest_of_current ++ [next_plant], rest)]
  end

  defp compute_next_gen(_mappings, current_set, []) do
    current_set
  end
end
