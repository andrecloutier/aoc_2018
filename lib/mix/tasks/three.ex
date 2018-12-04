defmodule Mix.Tasks.Three do
  use Mix.Task

  defmodule Board do
    defstruct board: nil, non_touching_ids: MapSet.new
  end

  def run(_args) do
    board =
      File.stream!("inputs/3.txt")
      |> Enum.map(&parse_input/1)
      |> Enum.reduce(initialize_board(), &process_line/2)

    part_one_count =
      board.board
      |> Enum.map(fn {_, row} ->
        Enum.count(row, fn {_, value} -> Enum.count(value) >= 2 end)
      end)
      |> Enum.sum

    IO.puts("Part 1 answer: #{part_one_count}")
    IO.puts("Part 2 answer: #{board.non_touching_ids |> MapSet.to_list |> Enum.at(0)}")
  end

  defp process_line([id, x_dimension, y_dimension, x_offset, y_offset], board) do
    updated_board = %Board{board | non_touching_ids: MapSet.put(board.non_touching_ids, id)}

    coordinates_to_update =
      x_offset..(x_offset+x_dimension-1)
      |> Enum.map(fn x ->
        Enum.map(y_offset..(y_offset+y_dimension-1), fn(y) -> [x,y] end)
      end)
      |> Enum.concat()

    coordinates_to_update
    |> Enum.reduce(updated_board, fn ([x,y], %Board{board: b, non_touching_ids: non_touching_ids}) ->
      %Board{
        board: put_in(b[x][y], [id | b[x][y]]),
        non_touching_ids: if(b[x][y] != [], do: MapSet.difference(non_touching_ids, MapSet.new([id | b[x][y]])), else: non_touching_ids)
      }
    end)
  end

  defp initialize_board(size \\ 1000) do
    zero_indexed_size = size - 1

    empty_row = (0..zero_indexed_size) |> Enum.map(fn i -> {i, []} end)

    board = (0..zero_indexed_size)
    |> Enum.map(fn i -> {i, Map.new(empty_row)} end)
    |> Map.new

    %Board{board: board}
  end

  defp parse_input(line) do
    #1 @ 604,100: 17x27
    [id, _, offsets, dimensions] = line |> String.split()
    [x_offset, y_offset] = offsets |> String.trim(":") |> String.split(",") |> Enum.map(&String.to_integer/1)
    [x_dimension, y_dimension] = dimensions |> String.split("x") |> Enum.map(&String.to_integer/1)
    [id, x_dimension, y_dimension, x_offset, y_offset]
  end
end
