defmodule Mix.Tasks.Eleven do
  use Mix.Task

  def run(_args) do
    serial_number = 7165

    board =
      Enum.map((1..300), fn x ->
        Enum.map((1..300), fn y ->
          rack_id = x + 10
          power_level = (rack_id * y + serial_number) * rack_id
          hundreds_digit = if power_level < 100, do: 0, else: rem(div(power_level,100),10)
          final_power_level = hundreds_digit - 5
          {{x, y}, final_power_level}
        end)
      end)
      |> Enum.concat()
      |> Map.new()

    {top_x, top_y, _} = solve_part_one(board)
    IO.puts("Part 1 answer: #{top_x},#{top_y}")

    {max_x, max_y, max_size, _max_score, _prev_board} =
      Enum.reduce((2..300), {0,0,0,-9999,board}, fn size, {max_x, max_y, max_size, max_score, prev_board} ->
        IO.puts "Working on size #{size} out of 300..."
        new_board = calculate_for_size(board, prev_board, size)

        {{maybe_x, maybe_y}, maybe_max_score} = new_board |> Enum.max_by(fn {_, score} -> score end)

        if maybe_max_score > max_score do
          {maybe_x, maybe_y, size, maybe_max_score, Map.new(new_board)}
        else
          {max_x, max_y, max_size, max_score, Map.new(new_board)}
        end
      end)

    IO.puts("Part 2 answer: #{max_x},#{max_y},#{max_size}")
  end

  defp calculate_for_size(board, previous_board, size) do
    Stream.map((1..(300-size+1)), fn x ->
      Stream.map((1..(300-size+1)), fn y ->
        tl = Map.get(previous_board, {x,y})
        ys = Stream.map(0..(size-2), fn y_offset -> Map.get(board, {x+size-1,y+y_offset}) end) |> Enum.sum
        xs = Stream.map(0..(size-1), fn x_offset -> Map.get(board, {x+x_offset,y+size-1}) end) |> Enum.sum
        {{x,y}, tl+ys+xs}
      end)
    end)
    |> Enum.concat()
  end

  defp solve_part_one(board) do
    board
    |> Map.to_list()
    |> Enum.reduce({0,0,-99999}, fn {{x,y}, _power_level}, {_best_x, _best_y, top_score} = current_best ->
      grid_values =
        Enum.map((0..2), fn x_offset ->
          Enum.map((0..2), fn y_offset ->
            Map.get(board, {x+x_offset, y+y_offset})
          end)
        end)
        |> Enum.concat

      if Enum.any?(grid_values, &is_nil/1) do
        current_best
      else
        sum = Enum.sum(grid_values)
        if sum > top_score do
          {x, y, sum}
        else
          current_best
        end
      end
    end)
  end
end