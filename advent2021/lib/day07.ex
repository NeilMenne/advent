defmodule Day07 do
  @moduledoc false

  def process_input(filename) do
    filename
    |> File.read!()
    |> String.trim_trailing()
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
  end

  def part_one(crabs) do
    freq_map = Enum.frequencies(crabs)

    freq_map
    |> Map.keys()
    |> Map.new(&p1_calc_fuel_cost(&1, freq_map))
    |> min_val()
  end

  defp p1_calc_fuel_cost(curr, freq_map) do
    total_cost =
      Enum.reduce(freq_map, 0, fn {pos, count}, cost ->
        cost + abs(curr - pos) * count
      end)

    {curr, total_cost}
  end

  def part_two(crabs) do
    freq_map = Enum.frequencies(crabs)

    uniq = Map.keys(freq_map)

    min = Enum.min(uniq)
    max = Enum.max(uniq)

    min..max
    |> Map.new(&p2_calc_fuel_cost(&1, freq_map))
    |> min_val()
  end

  defp p2_calc_fuel_cost(curr, freq_map) do
    total_cost =
      Enum.reduce(freq_map, 0, fn {pos, count}, cost ->
        n = abs(curr - pos)

        pos_cost = round(n * (n + 1) / 2)

        cost + pos_cost * count
      end)

    {curr, total_cost}
  end

  defp min_val(m), do: m |> Map.values() |> Enum.min()
end
