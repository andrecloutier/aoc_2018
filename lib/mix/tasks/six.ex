defmodule Mix.Tasks.Six do
  use Mix.Task

  def run(_args) do
    coordinates =
      File.stream!("inputs/6.txt")
      |> Enum.map(fn line ->
        line
        |> String.trim
        |> String.split(", ")
        |> Enum.map(&String.to_integer/1)
      end)


    [first, second] =
      [1000,1050]
      |> Task.async_stream(
           fn size -> recurse_over_coords(size, coordinates, %{}, &process_coord/3) end,
           timeout: :infinity
         )
      |> Enum.map(fn {:ok, r} -> r end)

    first_soln =
      second
      |> Map.to_list()
      |> Enum.filter(fn {key, count} -> first[key] == count end)
      |> Enum.map(fn {_key, count} -> count end)
      |> Enum.max
    IO.puts("Part 1 answer: #{first_soln}")

    second_soln = recurse_over_coords(1000, coordinates, 0, &part2_process_coord/3)
    IO.puts("Part 2 answer: #{second_soln}")
  end

  defp recurse_over_coords(grid_size, coordinates, initial_agg, func) do
    (-grid_size..grid_size-1)
    |> Enum.reduce(initial_agg, fn y, agg ->
      (-grid_size..grid_size-1)
        |> Enum.reduce(agg, fn x, agg2 ->
        func.([x,y], coordinates, agg2)
      end)
    end)
  end

  defp part2_process_coord([x,y], coordinates, agg) do
    distance =
      coordinates
      |> Enum.map(fn [x1, y2] -> abs(x-x1) + abs(y-y2) end)
      |> Enum.sum

    if distance < 10000 do
      agg+1
    else
      agg
    end
  end

  defp process_coord([x,y], coordinates, agg) do
    distances =
      coordinates
      |> Enum.map(fn [x1, y2] -> [[x1, y2], abs(x-x1) + abs(y-y2)] end)
      |> Enum.sort_by(fn [_, n] -> n end)

    [[first_xy, first_distance] | rest] = distances
    [[_, second_distance] | _] = rest

    if first_distance == second_distance do
      agg
    else
      put_in(agg[first_xy], (agg[first_xy] || 0) + 1)
    end
  end
end