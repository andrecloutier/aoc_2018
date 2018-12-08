defmodule Mix.Tasks.Eight do
  use Mix.Task

  defmodule Node do
    defstruct children: [], metadata: []
  end

  def run(_args) do
    [root, _] =
      File.stream!("inputs/8.txt")
      |> Enum.at(0)
      |> String.trim()
      |> String.split(" ")
      |> Enum.map(&String.to_integer/1)
      |> build_tree

    meta_sum = sum_metadata(root)
    IO.puts("Part 1 answer: #{meta_sum}")

    part_2 = value_of_node(root)
    IO.puts("Part 2 answer: #{part_2}")
  end

  defp build_tree(inputs) do
    [num_children | rest1] = inputs
    [num_metadata | rest2] = rest1

    child_data = build_children(num_children, rest2)

    rest3 = (Enum.at(child_data, -1) || [nil, rest2]) |> Enum.at(-1)

    {metadata_values, rest4} = rest3 |> Enum.split(num_metadata)

    n = %Node{
      children: child_data |> Enum.map(fn [child_node, _remaining_input] -> child_node end),
      metadata: metadata_values
    }

    [n, rest4]
  end

  defp build_children(0, _inputs), do: []
  defp build_children(remaining_children, inputs) do
    [n, remaining_input] = build_tree(inputs)
    [[n, remaining_input] | build_children(remaining_children-1, remaining_input)]
  end

  defp sum_metadata(nil), do: 0
  defp sum_metadata(n) do
    n.children
    |> Enum.map(fn child -> sum_metadata(child) end)
    |> Enum.sum()
    |> Kernel.+(n.metadata |> Enum.sum)
  end

  defp value_of_node(%Node{children: [], metadata: metadata}), do: Enum.sum(metadata)
  defp value_of_node(%Node{children: children, metadata: metadata}) do
    metadata
    |> Enum.filter(fn v -> v > 0 end)
    |> Enum.map(fn value ->
      n = Enum.at(children, value-1)
      if n == nil, do: 0, else: value_of_node(n)
    end)
    |> Enum.sum
  end
end