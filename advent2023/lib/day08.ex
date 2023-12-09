defmodule Advent2023.Day08 do
  def process_input(file_loc) do
    [instruction_line, node_str] =
      file_loc
      |> File.read!()
      |> String.trim_trailing()
      |> String.split("\n\n")

    instructions =
      instruction_line
      |> String.downcase()
      |> String.codepoints()
      |> Enum.map(&String.to_atom/1)

    %{
      instructions: instructions,
      graph: create_graph(node_str)
    }
  end

  defp create_graph(node_str) do
    regex = ~r/(\w+)\s*=\s*\((\w+),\s*(\w+)\)/

    node_str
    |> String.split("\n")
    |> Map.new(fn line ->
      [_, src, left, right] = Regex.run(regex, line)

      {src, %{l: left, r: right}}
    end)
  end

  defp all_zs(pos), do: pos == "ZZZ"

  @doc """
  Starting at AAA, follow the left/right instructions. How many steps are
  required to reach ZZZ?
  """
  def part1(%{instructions: instrs, graph: g}, start \\ "AAA", end_fn \\ &all_zs/1) do
    instrs
    |> Stream.cycle()
    |> Enum.reduce_while(%{len: 0, pos: start}, fn instr, acc ->
      next = g[acc.pos][instr]

      if end_fn.(next) do
        {:halt, acc.len + 1}
      else
        {:cont, %{acc | len: acc.len + 1, pos: next}}
      end
    end)
  end

  @doc """
  Simultaneously start on every node that ends with A. How many steps does it
  take before you're only on nodes that end with Z?
  """
  def part2(%{graph: g} = input) do
    ps = g |> Map.keys() |> start_ps()

    [h | rest] =
      ps
      |> Enum.map(fn p -> Task.async(__MODULE__, :part1, [input, p, &ends_with_z/1]) end)
      |> Task.await_many(:infinity)

    Enum.reduce(rest, h, &lcm/2)
  end

  defp start_ps(ps), do: Enum.filter(ps, &String.ends_with?(&1, "A"))

  defp ends_with_z(pos), do: String.ends_with?(pos, "Z")

  defp lcm(0, 0), do: 0
  defp lcm(a, b), do: div(a * b, Integer.gcd(a, b))
end
