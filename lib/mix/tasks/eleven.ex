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