defmodule Mix.Tasks.One do
  use Mix.Task

  defmodule AggResult do
    defstruct first_dupe: nil, previously_seen: MapSet.new(), current: 0
  end

  def run(_args) do
    input =
      File.stream!("inputs/1.txt")
      |> Enum.map(&parse_int/1)

    IO.puts("Part 1 answer: #{Enum.sum(input)}")

    res = find_result(input, %AggResult{})
    IO.puts("Part 2 answer: #{res.first_dupe}")
  end

  defp parse_int(str) do
    {i, _} = Integer.parse(str)
    i
  end

  defp find_result(input, %AggResult{first_dupe: nil} = aggregate) do
    new_agg = Enum.reduce(input, aggregate, &accumulator/2)
    find_result(input, new_agg)
  end

  defp find_result(_input, %AggResult{} = aggregate), do: aggregate

  defp accumulator(x, %AggResult{first_dupe: nil} = agg) do
    current = agg.current + x
    first_dupe = if MapSet.member?(agg.previously_seen, current), do: current, else: nil

    %AggResult{
      agg
      | current: current,
        first_dupe: first_dupe,
        previously_seen: MapSet.put(agg.previously_seen, current)
    }
  end

  defp accumulator(_x, agg), do: agg
end
