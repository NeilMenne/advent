defmodule Day08 do
  @moduledoc false

  def process_input(filename) do
    filename
    |> File.stream!()
    |> Enum.map(&parse_line/1)
  end

  def parse_line(line) do
    [patterns, outputs] = String.split(line, "|", trim: true)

    patterns =
      patterns
      |> String.split()
      |> Enum.map(&to_set/1)

    outputs =
      outputs
      |> String.split()
      |> Enum.map(&to_set/1)

    %{
      patterns: patterns,
      outputs: outputs
    }
  end

  defp to_set(str) do
    str
    |> String.codepoints()
    |> MapSet.new()
  end

  # respectively:  1, 7, 4, 8
  @unique_lengths [2, 3, 4, 7]

  @doc """
  In the output values, how many times do digits 1, 4, 7, or 8 appear?

  Exploiting the fact that these digits have unique numbers of activated
  segments, we can just look for those lengths in the outputs
  """
  def part_one(entries) do
    entries
    |> Enum.flat_map(& &1.outputs)
    |> Enum.filter(&by_length/1)
    |> Enum.count()
  end

  def by_length(set) do
    Enum.count(set) in @unique_lengths
  end

  @doc """
  For each entry, determine all of the wire/segment connections and decode the
  four-digit output values. What do you get if you add up all of the output
  values?
  """
  def part_two(entries) do
    entries
    |> Enum.map(&resolve_patterns/1)
    |> Enum.map(&entry_to_number/1)
    |> Enum.sum()
  end

  def resolve_patterns(%{patterns: unresolved} = entry) do
    grouped = Enum.group_by(unresolved, &Enum.count/1)

    unresolved = Map.take(grouped, [5, 6])

    map =
      Enum.reduce(grouped, %{}, fn {len, [val | _]}, acc ->
        case len do
          2 -> Map.put(acc, 1, val)
          3 -> Map.put(acc, 7, val)
          4 -> Map.put(acc, 4, val)
          7 -> Map.put(acc, 8, val)
          _ -> acc
        end
      end)

    resolved = resolve_patterns(unresolved, map)

    entry
    |> Map.put(:resolved, resolved)
    |> Map.delete(:patterns)
  end

  defp resolve_patterns(%{5 => [], 6 => []}, map) do
    Map.new(map, fn {k, v} -> {v, k} end)
  end

  defp resolve_patterns(%{6 => [x | rest]} = unresolved, map) do
    number =
      cond do
        is_nine?(x, map) -> 9
        is_zero?(x, map) -> 0
        true -> 6
      end

    resolve_patterns(%{unresolved | 6 => rest}, Map.put(map, number, x))
  end

  defp resolve_patterns(%{5 => [x | rest]} = unresolved, map) do
    number =
      cond do
        is_five?(x, map) -> 5
        is_two?(x, map) -> 2
        true -> 3
      end

    resolve_patterns(%{unresolved | 5 => rest}, Map.put(map, number, x))
  end

  defp is_nine?(x, %{4 => four}) do
    Enum.empty?(MapSet.difference(four, x))
  end

  defp is_zero?(x, %{4 => four, 7 => seven}) do
    Enum.empty?(MapSet.difference(seven, x)) and not MapSet.disjoint?(four, x)
  end

  defp is_five?(x, %{4 => four, 6 => six}) do
    MapSet.disjoint?(MapSet.difference(six, x), four)
  end

  defp is_two?(x, %{4 => four}) do
    Enum.count(MapSet.union(x, four)) == 7
  end

  defp entry_to_number(%{outputs: output, resolved: resolved}) do
    output
    |> Enum.reverse()
    |> Enum.with_index()
    |> Enum.reduce(0, fn {dig, power}, acc ->
      digit = Map.fetch!(resolved, dig)

      acc + round(digit * :math.pow(10, power))
    end)
  end
end
