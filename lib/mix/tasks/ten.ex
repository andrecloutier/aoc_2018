defmodule Mix.Tasks.Ten do
  use Mix.Task

  def run(_args) do
    File.stream!("inputs/10.txt")
    |> Enum.map(&parse_line/1)
    |> print_and_loop(0)

  end

  defp print_and_loop(coords, num_loops) do
    min_maxes = get_min_maxes(coords)
    {_, _, min_y, max_y} = min_maxes

    if max_y - min_y < 15 do
      IO.puts "Part 1 solution:"
      print_board(coords, min_maxes)
      IO.puts "Part 2 solution: #{num_loops}"
    else
      coords
      |> advance_coords
      |> print_and_loop(num_loops+1)
    end
  end

  defp print_board(coords, {min_x, max_x, min_y, max_y}) do
    used_coords=
      coords
      |> Enum.map(fn {pos_x, pos_y, _, _} -> {pos_x, pos_y} end)
      |> MapSet.new()

    Enum.each(min_y..max_y, fn y ->
      Enum.map(min_x..max_x, fn x ->
        if MapSet.member?(used_coords, {x, y}), do: "#", else: "."
      end)
      |> IO.puts
    end)
  end

  defp get_min_maxes(coords) do
    {x,y, _, _} = coords |> Enum.at(0)
    Enum.reduce(
      coords,
      {x,y,x,y},
      fn {x_pos, y_pos, _, _}, {min_x, max_x, min_y, max_y} ->
        {Enum.min([x_pos, min_x]), Enum.max([x_pos, max_x]), Enum.min([y_pos, min_y]), Enum.max([y_pos, max_y])}
      end
    )
  end

  defp advance_coords(coords) do
    coords |> Enum.map(fn {x_pos, y_pos, x_vel, y_vel} -> {x_pos+x_vel, y_pos+y_vel, x_vel, y_vel} end)
  end

  defp parse_line(line) do
    [_, apos_x, apos_y, _, avel_x, avel_y, _] =
      line
      |> String.split("<")
      |> Enum.map(&String.split(&1, ">"))
      |> Enum.concat
      |> Enum.map(&String.split(&1, ","))
      |> Enum.concat

    [apos_x, apos_y, avel_x, avel_y]
    |> Enum.map(&String.trim/1)
    |> Enum.map(&String.to_integer/1)
    |> List.to_tuple
  end
end