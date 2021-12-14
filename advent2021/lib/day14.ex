defmodule Day14 do
  @moduledoc false

  def process_input(filename) do
    [template_str, rules_str] =
      filename
      |> File.read!()
      |> String.split("\n\n")

    rules =
      rules_str
      |> String.split("\n")
      |> Enum.reject(&(&1 == ""))
      |> Map.new(fn str ->
        m = Regex.named_captures(~r/(?<left>[A-Z])(?<right>[A-Z]) -> (?<middle>[A-Z])/, str)

        {[m["left"], m["right"]], m["middle"]}
      end)

    template_arr =
      template_str
      |> String.trim_trailing()
      |> String.codepoints()

    {template_arr, rules}
  end

  def part_one(template_arr, rules), do: solve(template_arr, rules, 10)

  def part_two(template_arr, rules), do: solve(template_arr, rules, 40)

  @doc """
  1. Expand the polymer template N times
  2. Count the frequency of each letter
  3. Subtract the least frequent character's occurrences from the most
     frequent's occurrences
  """
  def solve(template_arr, rules, times) do
    last_char = List.last(template_arr)

    {min, max} =
      template_arr
      |> to_pairs_map()
      |> repeat_expansion(rules, times)
      |> pair_map_to_frequencies(last_char)
      |> Map.values()
      |> Enum.min_max()

    max - min
  end

  defp to_pairs_map(template_arr) do
    template_arr
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.frequencies()
  end

  defp repeat_expansion(pairs, _rules, 0), do: pairs

  defp repeat_expansion(pairs, rules, times),
    do: repeat_expansion(pair_insertion(pairs, rules), rules, times - 1)

  # NOTE: the expansion inserts a middle character between an adjacent pair; for
  # the next iteration then, we will see two pairs where the current iteration
  # had one. finally, the current pair is no longer included, so that is
  # subtracted out from the map
  defp pair_insertion(pairs_map, rules) do
    Enum.reduce(pairs_map, pairs_map, fn {[left, right] = key, count}, acc ->
      mid = Map.fetch!(rules, key)

      acc
      |> Map.update([left, mid], count, &(&1 + count))
      |> Map.update([mid, right], count, &(&1 + count))
      |> Map.update!(key, &(&1 - count))
    end)
  end

  defp pair_map_to_frequencies(pair_map, last_char) do
    Enum.reduce(pair_map, %{last_char => 1}, fn {[left, _], v}, acc ->
      Map.update(acc, left, v, &(&1 + v))
    end)
  end
end
