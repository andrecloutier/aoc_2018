defmodule Mix.Tasks.Nine do
  use Mix.Task

  defmodule ListIterator do
    defstruct head: [], tail: [], current: nil, head_length: 0, tail_length: 0
  end

  def run(_args) do
    test_part_one()

    # "430 players; last marble is worth 71588 points"
    [num_players, last_marble_points] = [430, 71588]
    winning_score = winning_score(num_players, last_marble_points)
    IO.puts("Part 1 answer: 422748==#{winning_score}")

    winning_score2 = winning_score(num_players, last_marble_points*100)
    IO.puts("Part 2 answer: #{winning_score2}")
  end

  defp test_part_one() do
    tests = [
      [9, 25, 32],
      [10, 1618, 8317],
      [13, 7999, 146373],
      [17, 1104, 2764],
      [21, 6111, 54718],
      [30, 5807, 37305]
    ]

    tests
    |> Enum.each(fn [num_players, last_marble_points, correct_answer] ->
      score = winning_score(num_players, last_marble_points)
      IO.puts("#{correct_answer == score} #{num_players} #{last_marble_points} #{correct_answer}==#{score}")
    end)
  end

  defp winning_score(num_players, last_marble_points) do
#    build_board([0], 0, 1, 1, num_players, last_marble_points+1, %{})
    build_board_fast(%ListIterator{current: 1}, 1, 2, num_players, last_marble_points+1, %{})
    |> Map.to_list()
    |> Enum.map(fn {_, score} -> score end)
    |> Enum.max
  end

  defp build_board_fast(_, _, current_marble, _, current_marble, score), do: score
  defp build_board_fast(marbles, player_number, current_marble, num_players, last_marble_score, score) when rem(current_marble, 23) == 0 do
#    print_marbles(marbles)
    {removed_marble_value, new_marbles} = marbles |> advance_by(-7) |>  remove_value()
    new_score = put_in(score[player_number], (score[player_number] || 0) + current_marble + removed_marble_value)
    build_board_fast(new_marbles, rem(player_number+1, num_players), current_marble+1, num_players, last_marble_score, new_score)
  end
  defp build_board_fast(marbles, player_number, current_marble, num_players, last_marble_score, score) do
#    print_marbles(marbles)
    new_marbles = marbles |> advance_by(2) |> insert_value(current_marble)
    build_board_fast(new_marbles, rem(player_number+1, num_players), current_marble+1, num_players, last_marble_score, score)
  end

  defp print_marbles(%ListIterator{head: head, current: current, tail: tail} = m) do
    [Enum.reverse(head), [current], tail]
    |> Enum.concat()
    |> Enum.join(" ")
    |> IO.puts

    m
  end

  defp advance_by(%ListIterator{} = it, n) when n >= 0, do: do_advance_by(it, n)
  defp advance_by(%ListIterator{head_length: head_length} = it, n) when n < 0 and head_length > abs(n) do
    do_advance_by(it, n)
  end
  defp advance_by(%ListIterator{head_length: head_length, current: nil, tail_length: tail_length} = it, n) when n < 0 do
    do_advance_by(it, head_length + tail_length + n)
  end
  defp advance_by(%ListIterator{head_length: head_length, tail_length: tail_length} = it, n) when n < 0 do
    do_advance_by(it, head_length + tail_length + n + 1)
  end

  defp do_advance_by(tuple, 0), do: tuple

#  defp do_advance_by(%ListIterator{head: head, current: nil, tail: []} = it, n) when n < 0 do
#    [next_current | next_tail] = Enum.reverse(head)
#
#    %ListIterator{it | head: [], current: next_current, tail: next_tail, head_length: 0, tail_length: it.head_length}
#    |> do_advance_by(n - 1)
#  end
#  defp do_advance_by(%ListIterator{head: head, current: current, tail: []} = it, n) when n < 0 do
#    %ListIterator{it | head: [current | head], current: nil, tail: [], head_length: it.head_length+1, tail_length: 0}
#    |> do_advance_by(n - 1)
#  end
  defp do_advance_by(%ListIterator{head: head, current: current, tail: tail} = it, n) when n < 0 do
    next_tail = [current | tail]
    [next_current | next_head] = head

    %ListIterator{it | head: next_head, current: next_current, tail: next_tail, head_length: it.head_length-1, tail_length: it.tail_length+1}
    |> do_advance_by(n + 1)
  end

  defp do_advance_by(%ListIterator{head: head, current: nil, tail: []} = it, n) when n > 0 do
    [next_current | next_tail] = Enum.reverse(head)

    %ListIterator{it | head: [], current: next_current, tail: next_tail, head_length: 0, tail_length: it.head_length}
    |> do_advance_by(n - 1)
  end
  defp do_advance_by(%ListIterator{head: head, current: current, tail: []} = it, n) when n > 0 do
    %ListIterator{it | head: [current | head], current: nil, tail: [], head_length: it.head_length+1, tail_length: 0}
    |> do_advance_by(n - 1)
  end
  defp do_advance_by(%ListIterator{head: head, current: current, tail: tail} = it, n) when n > 0 do
    next_head = [current | head]
    [next_current | next_tail] = tail

    %ListIterator{it | head: next_head, current: next_current, tail: next_tail, head_length: it.head_length+1, tail_length: it.tail_length-1}
    |> do_advance_by(n - 1)
  end

  defp insert_value(%ListIterator{head: head, current: nil, tail: tail} = it, value) do
    %ListIterator{it | head: head, current: value, tail: tail}
  end
  defp insert_value(%ListIterator{head: head, current: current, tail: tail} = it, value) do
    %ListIterator{it | head: head, current: value, tail: [current | tail], tail_length: it.tail_length+1}
  end

  defp remove_value(%ListIterator{head: head, current: nil, tail: []} = it) do
    [next_current | next_tail] = Enum.reverse(head)
    %ListIterator{it | head: [], current: next_current, tail: next_tail, head_length: 0, tail_length: it.head_length-1}
    |> remove_value()
  end
  defp remove_value(%ListIterator{head: head, current: current, tail: []} = it) do
    [next_current | next_tail] = Enum.reverse(head)
    it2 = %ListIterator{it | head: [], current: next_current, tail: next_tail, head_length: it.head_length, tail_length: 0}
    {current, it2}
  end
  defp remove_value(%ListIterator{head: head, current: current, tail: [next_current | next_tail]} = it) do
    it2 = %ListIterator{it | head: head, current: next_current, tail: next_tail, tail_length: it.tail_length-1}
    {current, it2}
  end


#
#
#
#  defp build_board(_, _, current_marble, _, _, current_marble, score), do: score
#  defp build_board(marbles, player_number, current_marble, current_pos, num_players, last_marble_score, score) do
#    if rem(current_marble, 23) == 0 do
#      remove_pos = if current_pos - 7 < 0, do: (current_pos - 7 + length(marbles)) |> zero_adjust, else: current_pos - 7
#      {removed_marble_value, new_marbles} = List.pop_at(marbles, remove_pos)
#
#      new_score = put_in(score[player_number], (score[player_number] || 0) + current_marble + removed_marble_value)
#      build_board(new_marbles, rem(player_number+1, num_players), current_marble+1, remove_pos, num_players, last_marble_score, new_score)
#    else
#      insert_pos = rem(current_pos + 2, length(marbles) + 1) |> zero_adjust
#
#      new_marbles = List.insert_at(marbles, insert_pos, current_marble)
#      build_board(new_marbles, rem(player_number+1, num_players), current_marble+1, insert_pos, num_players, last_marble_score, score)
#    end
#  end
#
#  defp zero_adjust(0), do: 1
#  defp zero_adjust(n), do: n

end