defmodule Day09 do
  @moduledoc false

  def process_input(filename) do
    File.stream!(filename)
    |> Enum.map(&to_ints/1)
    |> to_map()
  end

  defp to_ints(str) do
    str
    |> String.trim_trailing()
    |> String.codepoints()
    |> Enum.map(&String.to_integer/1)
  end

  defp to_map([i | _] = inputs) do
    width = length(i) - 1
    height = length(inputs) - 1

    for h <- 0..height, w <- 0..width do
      pos = {h, w}
      val = get_in(inputs, [Access.at(h), Access.at(w)])

      {pos, val}
    end
    |> Map.new()
  end

  def part_one(input) do
    input
    |> Enum.filter(&low_point?(&1, input))
    |> Enum.map(fn {_pos, val} -> val + 1 end)
    |> Enum.sum()
  end

  defp list_neighbors({h, w}, map) do
    [{h, w - 1}, {h, w + 1}, {h - 1, w}, {h + 1, w}]
    |> Enum.filter(&Map.has_key?(map, &1))
  end

  defp low_point?({pos, val}, map) do
    pos
    |> list_neighbors(map)
    |> Enum.map(&Map.get(map, &1))
    |> Enum.any?(&(val >= &1))
    |> Kernel.not()
  end

  def part_two(input) do
    low_points =
      input
      |> Enum.filter(&low_point?(&1, input))
      |> Enum.map(&elem(&1, 0))

    basins = collect_basins(low_points, input)

    [x, y, z | _] =
      basins
      |> Enum.map(fn {_, ps} -> Enum.count(ps) end)
      |> Enum.sort(:desc)

    x * y * z
  end

  defp collect_basins(low_points, input) do
    avail =
      input
      |> Enum.reject(fn {_pos, val} -> val == 9 end)
      |> Map.new()

    output =
      Enum.reduce(low_points, %{avail: avail, basins: %{}}, fn pos, acc ->
        basin = from_point(pos, acc.avail)

        avail = Map.drop(acc.avail, basin)

        acc
        |> put_in([:basins, pos], basin)
        |> Map.put(:avail, avail)
      end)

    output.basins
  end

  defp from_point(pos, avail) do
    from_point_recur(avail, [pos], MapSet.new())
  end

  defp from_point_recur(_, [], basin), do: MapSet.to_list(basin)

  defp from_point_recur(avail, to_try, basin) do
    to_try =
      to_try
      |> Enum.flat_map(&list_neighbors(&1, avail))
      |> Enum.filter(&Map.has_key?(avail, &1))
      |> Enum.reject(&MapSet.member?(basin, &1))

    basin = MapSet.union(basin, MapSet.new(to_try))

    from_point_recur(avail, to_try, basin)
  end
end
