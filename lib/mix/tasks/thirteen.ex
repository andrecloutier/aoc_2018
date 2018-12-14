defmodule Mix.Tasks.Thirteen do
  use Mix.Task

  def run(_args) do
    board =
      File.stream!("inputs/13.txt")
      |> Enum.map(fn line -> line |> String.codepoints |> Enum.with_index end)
      |> Enum.with_index()
      |> Enum.map(fn {line, y} ->
        Enum.map(line, fn {char, x} -> {{x,y}, char} end)
      end)
      |> Enum.concat()

    carts =
      board
      |> Enum.filter(fn {_coords, char} -> char == ">" || char == "^" || char == "<" || char == "v" end)
      |> Enum.map(fn {coords, char} -> {coords, char, 1} end)

    board_without_carts =
      board
      |> Enum.map(fn {coords, char} ->
        next_char = case char do
          ">" -> "-"
          "<" -> "-"
          "^" -> "|"
          "v" -> "|"
          c -> c
        end
        {coords, next_char}
      end)
      |> Map.new()

    {crash_x, crash_y} = recurse_till_crash(board_without_carts, carts, [], false)
    IO.puts("Part 1 answer: #{crash_x},#{crash_y}")

    {last_x, last_y} = recurse_till_crash(board_without_carts, carts, [], true)
    IO.puts("Part 2 answer: #{last_x},#{last_y}")
  end

  defp recurse_till_crash(_board_without_carts, [{coord,_,_}], [], _is_part_2 = true) do
    coord
  end

  defp recurse_till_crash(_board_without_carts, [], [{coord,_,_}], _is_part_2 = true) do
    coord
  end

  defp recurse_till_crash(board_without_carts, visited_carts, [], is_part_2) do
    sorted_carts = visited_carts |> Enum.sort_by(fn {{x,y},_,_} -> {y,x} end)
    recurse_till_crash(board_without_carts, [], sorted_carts, is_part_2)
  end

  defp recurse_till_crash(board_without_carts, visited_carts, [current_cart | remaining_carts], is_part_2) do
    {{x,y}, char, turn_num} = current_cart

    next_coord =
      case char do
        ">" -> {x+1,y}
        "<" -> {x-1,y}
        "^" -> {x,y-1}
        "v" -> {x,y+1}
      end

    is_there_a_crash = Stream.concat(visited_carts, remaining_carts) |> Enum.any?(fn {coord, _, _} -> coord == next_coord end)
    if is_there_a_crash do
      if is_part_2 do
        next_visited_carts = visited_carts |> Enum.reject(fn {coord, _, _} -> coord == next_coord end)
        next_remaining_carts = remaining_carts |> Enum.reject(fn {coord, _, _} -> coord == next_coord end)
        recurse_till_crash(board_without_carts, next_visited_carts, next_remaining_carts, is_part_2)
      else
        next_coord
      end
    else
      # It turns left the first time, goes straight the second time,
      # turns right the third time, and then repeats those directions
      # starting again with left the fourth time, straight the fifth time, and so on.

      {next_char, next_turn_num} =
        case {char, Map.get(board_without_carts, next_coord), turn_num} do
          {">", "-", _} -> {">", turn_num}
          {"<", "-", _} -> {"<", turn_num}
          {"^", "|", _} -> {"^", turn_num}
          {"v", "|", _} -> {"v", turn_num}

          {"^", "\\", _} -> {"<", turn_num}
          {">", "\\", _} -> {"v", turn_num}
          {"v", "\\", _} -> {">", turn_num}
          {"<", "\\", _} -> {"^", turn_num}

          {"<", "/", _} -> {"v", turn_num}
          {"v", "/", _} -> {"<", turn_num}
          {"^", "/", _} -> {">", turn_num}
          {">", "/", _} -> {"^", turn_num}

          {"v", "+", 1} -> {">", 2}
          {">", "+", 1} -> {"^", 2}
          {"^", "+", 1} -> {"<", 2}
          {"<", "+", 1} -> {"v", 2}

          {direction, "+", 2} -> {direction, 3}

          {"v", "+", 3} -> {"<", 1}
          {">", "+", 3} -> {"v", 1}
          {"^", "+", 3} -> {">", 1}
          {"<", "+", 3} -> {"^", 1}
        end

      recurse_till_crash(board_without_carts, [{next_coord, next_char, next_turn_num} | visited_carts], remaining_carts, is_part_2)
    end
  end
end
