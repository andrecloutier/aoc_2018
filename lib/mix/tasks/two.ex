defmodule Mix.Tasks.Two do
  use Mix.Task

  defmodule AggResult do
    defstruct found_two: false, found_three: false, count_two: 0, count_three: 0
  end

  def run(_args) do
    agg =
      File.stream!("inputs/2.txt")
      |> Enum.reduce(%AggResult{}, &part_one_process_line/2)

    IO.puts("Part 1 answer: #{agg.count_two * agg.count_three}")

    solution =
      File.stream!("inputs/2.txt")
      |> Enum.map(fn l -> l end)
      |> part_two_process_lines()

    IO.puts("Part 2 answer: #{solution}")
  end

  def part_two_process_lines([current_line | rest]) do
    item = Enum.find(rest, fn l -> part_two_are_one_char_apart?(current_line, l) end)

    if item != nil do
      cp_one = String.codepoints(current_line)
      cp_two = String.codepoints(item)

      Enum.zip(cp_one, cp_two)
      |> Enum.map(fn {a, b} -> if a == b, do: a, else: "" end)
      |> Enum.join()
    else
      part_two_process_lines(rest)
    end
  end

  def part_two_are_one_char_apart?(line_one, line_two) do
    cp_one = String.codepoints(line_one)
    cp_two = String.codepoints(line_two)

    if Enum.count(cp_one) != Enum.count(cp_two) do
      raise "lines aren't equal"
    end

    Enum.count(Enum.zip(cp_one, cp_two), fn {a, b} -> a != b end) == 1
  end

  def part_one_process_line(line, agg) do
    chars = String.codepoints(line)
    unique_chars = MapSet.new(chars) |> MapSet.to_list()
    new_agg = part_one_find_dupe_chars(unique_chars, chars, agg)

    %AggResult{
      found_two: false,
      found_three: false,
      count_two: if(new_agg.found_two, do: new_agg.count_two + 1, else: new_agg.count_two),
      count_three: if(new_agg.found_three, do: new_agg.count_three + 1, else: new_agg.count_three)
    }
  end

  def part_one_find_dupe_chars([], _subject, agg), do: agg

  def part_one_find_dupe_chars([current_char | chars_rest], subject, agg) do
    count = Enum.count(subject, fn x -> x == current_char end)

    new_agg = %AggResult{
      agg
      | found_two: agg.found_two || count == 2,
        found_three: agg.found_three || count == 3
    }

    part_one_find_dupe_chars(chars_rest, subject, new_agg)
  end
end

# abcdef contains no letters that appear exactly two or three times.
# bababc contains two a and three b, so it counts for both.           (2=1, 3=1)
# abbcde contains two b, but no letter appears exactly three times.   (2=2, 3=1)
# abcccd contains three c, but no letter appears exactly two times.   (2=2, 3=2)
# aabcdd contains two a and two d, but it only counts once.           (2=3, 3=2)
# abcdee contains two e.                                              (2=4, 3=2)
# ababab contains three a and three b, but it only counts once.       (2=4, 3=3)
