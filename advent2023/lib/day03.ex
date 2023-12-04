defmodule Advent2023.Day03 do
  def process_input(file_loc) do
    file_loc
    |> File.stream!()
    |> Enum.map(&String.trim_trailing/1)
    |> Enum.with_index()
    |> Enum.map(&parse_line/1)
    |> Enum.reduce(%{}, &Map.merge/2)
  end

  defp parse_line({line, row_idx}) do
    # this returns the starting position _and_ the length
    num_idx = Regex.scan(~r/\d+/, line, return: :index)

    row =
      Enum.reduce(num_idx, %{}, fn [{s, l}], m ->
        number =
          line
          |> String.slice(s, l)
          |> String.to_integer()

        Map.put(m, {s, row_idx}, {number, l})
      end)

    sym_idx = Regex.scan(~r/[^0-9.]/, line, return: :index)

    Enum.reduce(sym_idx, row, fn [{s, l}], m ->
      sym = String.slice(line, s, l)

      Map.put(m, {s, row_idx}, sym)
    end)
  end

  @doc """
  If you can add up all the part numbers in the engine schematic, it should be
  easy to work out which part is missing.

  NOTE: any number adjacent to a symbol, even diagonally, is a "part number" and
  should be included in your sum.
  """
  def part1(grid) do
    symbols =
      grid
      |> Enum.reject(&is_num?/1)
      |> MapSet.new(&elem(&1, 0))

    grid
    |> Enum.filter(&is_num?/1)
    |> Enum.filter(&adjacent_symbol?(&1, symbols))
    |> Enum.map(fn {_coord, {num, _l}} -> num end)
    |> Enum.sum()
  end

  defp is_num?({_pos, {_val, _len}}), do: true
  defp is_num?(_), do: false

  defp adjacent_symbol?({{c, r}, {_, l}}, symset) do
    for c0 <- (c - 1)..(c + l),
        r0 <- (r - 1)..(r + 1),
        into: MapSet.new() do
      {c0, r0}
    end
    |> MapSet.disjoint?(symset)
    |> Kernel.not()
  end

  @doc """
  What is the sum of all of the gear ratios in your engine schematic?

  NOTE: A gear is any * symbol that is adjacent to **exactly** two part numbers.
  Its gear ratio is the result of multiplying those two numbers together.
  """
  def part2(grid) do
    # the list of all possible gears
    pos_gears =
      grid
      |> Enum.filter(&is_gear?/1)
      |> Enum.map(&elem(&1, 0))

    # the list of all `{pos, {num, len}}` (aka the numbers)
    nums =
      grid
      |> Enum.filter(&is_num?/1)

    # for each possible gear, the number of adjacent digits must be exactly 2
    Enum.reduce(pos_gears, 0, fn g, acc ->
      symset = MapSet.new([g])

      adjacent_nums = Enum.filter(nums, &adjacent_symbol?(&1, symset))

      if length(adjacent_nums) == 2 do
        [{_, {x0, _}}, {_, {x1, _}}] = adjacent_nums

        acc + x0 * x1
      else
        acc
      end
    end)
  end

  defp is_gear?({_, "*"}), do: true
  defp is_gear?(_), do: false
end
