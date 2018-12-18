defmodule Mix.Tasks.Sixteen do
  use Mix.Task
  use Bitwise

  def run(_args) do
    part_1_inputs =
      File.stream!("inputs/16.txt")
      |> Stream.chunk_every(4)
      |> Stream.filter(fn parts -> parts |> Enum.at(0) |> String.starts_with?("Before:") end)
      |> Enum.map(fn [beforeStr, cmdStr, afterStr, _] ->
        before =
          beforeStr |> String.trim |> String.split("[") |> Enum.at(1) |> String.trim("]") |> String.split(",")
          |> Enum.map(fn p -> p |> String.trim |> String.to_integer end)

        command = cmdStr |> String.trim |> String.split(" ") |> Enum.map(fn p -> p |> String.to_integer end)

        aftr = afterStr |> String.trim |> String.split("[") |> Enum.at(1) |> String.trim("]") |> String.split(",")
               |> Enum.map(fn p -> p |> String.trim |> String.to_integer end)


        [before, command, aftr]
      end)

    funcs = [
      &addr/2,
      &addi/2,
      &multr/2,
      &multi/2,
      &banr/2,
      &bani/2,
      &barr/2,
      &bari/2,
      &setr/2,
      &seti/2,
      &gtir/2,
      &gtri/2,
      &gtrr/2,
      &eqir/2,
      &eqri/2,
      &eqrr/2
    ]

    part_1_answer =
      part_1_inputs
      |> Enum.count(fn [before, command, aftr] ->
        Enum.count(funcs, fn func -> func.(before, command) == aftr end) >= 3
      end)
    IO.puts("Part 1 answer: #{part_1_answer}")

    op_map = build_op_map(%{}, funcs, part_1_inputs)

    [part_2_soln, _, _, _] =
      File.stream!("inputs/16.txt")
      |> Stream.chunk_every(4)
      |> Stream.reject(fn parts -> parts |> Enum.at(0) |> String.starts_with?("Before:") end)
      |> Stream.concat()
      |> Stream.map(&String.trim/1)
      |> Stream.reject(fn s -> s == "" end)
      |> Stream.map(fn s -> s |> String.split(" ") |> Enum.map(&String.to_integer/1) end)
      |> Enum.reduce([0,0,0,0], fn [opcode, _, _, _] = command, registers ->
        Map.get(op_map, opcode).(registers, command)
      end)

    IO.puts("Part 2 answer: #{part_2_soln}")
  end

  defp build_op_map(op_map, [], _inputs), do: op_map
  defp build_op_map(op_map, funcs, inputs) do
    new_ops =
      inputs
      |> Stream.map(fn [before, command, aftr] ->
        fns = funcs |> Enum.filter(fn func -> func.(before, command) == aftr end)
        if length(fns) == 1 do
          {command |> Enum.at(0), fns |> Enum.at(0)}
        else
          nil
        end
      end)
      |> Enum.reject(fn n -> n == nil end)

    newly_found_funs = Enum.map(new_ops, &elem(&1, 1))
    new_map = Map.new(new_ops) |> Map.merge(op_map)
    new_funcs = Enum.reject(funcs, fn fun -> Enum.member?(newly_found_funs, fun) end)
    build_op_map(new_map, new_funcs, inputs)
  end

  def addr(registers, [_opcode, in_a, in_b, out_c]) do
    result = Enum.at(registers, in_a) + Enum.at(registers, in_b)
    List.replace_at(registers, out_c, result)
  end

  def addi(registers, [_opcode, in_a, in_b, out_c]) do
    result = Enum.at(registers, in_a) + in_b
    List.replace_at(registers, out_c, result)
  end

  def multr(registers, [_opcode, in_a, in_b, out_c]) do
    result = Enum.at(registers, in_a) * Enum.at(registers, in_b)
    List.replace_at(registers, out_c, result)
  end

  def multi(registers, [_opcode, in_a, in_b, out_c]) do
    result = Enum.at(registers, in_a) * in_b
    List.replace_at(registers, out_c, result)
  end

  def banr(registers, [_opcode, in_a, in_b, out_c]) do
    result = Enum.at(registers, in_a) &&& Enum.at(registers, in_b)
    List.replace_at(registers, out_c, result)
  end

  def bani(registers, [_opcode, in_a, in_b, out_c]) do
    result = Enum.at(registers, in_a) &&& in_b
    List.replace_at(registers, out_c, result)
  end

  def barr(registers, [_opcode, in_a, in_b, out_c]) do
    result = Enum.at(registers, in_a) ||| Enum.at(registers, in_b)
    List.replace_at(registers, out_c, result)
  end

  def bari(registers, [_opcode, in_a, in_b, out_c]) do
    result = Enum.at(registers, in_a) ||| in_b
    List.replace_at(registers, out_c, result)
  end

  def setr(registers, [_opcode, in_a, _in_b, out_c]) do
    result = Enum.at(registers, in_a)
    List.replace_at(registers, out_c, result)
  end

  def seti(registers, [_opcode, in_a, _in_b, out_c]) do
    List.replace_at(registers, out_c, in_a)
  end

  def gtir(registers, [_opcode, in_a, in_b, out_c]) do
    result = if in_a > Enum.at(registers, in_b), do: 1, else: 0
    List.replace_at(registers, out_c, result)
  end

  def gtri(registers, [_opcode, in_a, in_b, out_c]) do
    result = if Enum.at(registers, in_a) > in_b, do: 1, else: 0
    List.replace_at(registers, out_c, result)
  end

  def gtrr(registers, [_opcode, in_a, in_b, out_c]) do
    result = if Enum.at(registers, in_a) > Enum.at(registers, in_b), do: 1, else: 0
    List.replace_at(registers, out_c, result)
  end

  def eqir(registers, [_opcode, in_a, in_b, out_c]) do
    result = if in_a == Enum.at(registers, in_b), do: 1, else: 0
    List.replace_at(registers, out_c, result)
  end

  def eqri(registers, [_opcode, in_a, in_b, out_c]) do
    result = if Enum.at(registers, in_a) == in_b, do: 1, else: 0
    List.replace_at(registers, out_c, result)
  end

  def eqrr(registers, [_opcode, in_a, in_b, out_c]) do
    result = if Enum.at(registers, in_a) == Enum.at(registers, in_b), do: 1, else: 0
    List.replace_at(registers, out_c, result)
  end
end
