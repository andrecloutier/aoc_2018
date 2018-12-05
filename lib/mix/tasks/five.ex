defmodule Mix.Tasks.Five do
  use Mix.Task

  def run(_args) do
    source_chars =
      File.stream!("inputs/5.txt")
      |> Enum.at(0)
      |> String.trim
      |> String.codepoints

    solution =
      source_chars
      |> do_until_no_changes
      |> Enum.count

    IO.puts("Part 1 answer: #{solution}")

    [_char, len] =
      source_chars
      |> Enum.map(&String.capitalize/1)
      |> Enum.uniq()
      |> Enum.map(fn c ->
        [
          c,
          source_chars
          |> Enum.reject(fn s -> String.capitalize(s) == String.capitalize(c) end)
          |> do_until_no_changes
          |> Enum.count
        ]
      end)
      |> Enum.min_by(fn [_, c] -> c end)

    IO.puts("Part 2 answer: #{len}")
  end

  def do_until_no_changes(current, last \\ nil)
  def do_until_no_changes(word, word), do: word
  def do_until_no_changes(current, _last) do
    current
    |> strip_dupes()
    |> do_until_no_changes(current)
  end

  def strip_dupes([]), do: []
  def strip_dupes([_ | []] = v), do: v
  def strip_dupes(points) do
    [a | rest1] = points
    [b | rest2] = rest1

    if a != b and String.capitalize(a) == String.capitalize(b) do
      strip_dupes(rest2)
    else
      [a | strip_dupes(rest1)]
    end
  end
end