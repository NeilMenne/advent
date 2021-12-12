defmodule Day11 do
  @moduledoc false

  def process_input(filename) do
    File.stream!(filename)
    |> Enum.map(fn str ->
      str
      |> String.trim_trailing()
      |> String.codepoints()
      |> Enum.map(&String.to_integer/1)
    end)
    |> to_grid()
  end

  defp to_grid(arrs) do
    for x <- 0..9, y <- 0..9 do
      {{x, y}, get_in(arrs, [Access.at(x), Access.at(y)])}
    end
    |> Map.new()
  end

  @doc """
  Visualize the state of the grid
  """
  def draw_grid(grid) do
    Enum.map(0..9, fn x ->
      str =
        for y <- 0..9 do
          Map.fetch!(grid, {x, y})
        end
        |> Enum.join()

      str <> "\n"
    end)
    |> IO.puts()
  end

  @doc """
  Perform a fixed number of rounds given an input grid
  """
  def part_one(grid) do
    %{flashed: flash_count} = do_rounds(grid, 100)

    flash_count
  end

  defp do_rounds(grid, count) do
    Enum.reduce(1..count, %{flashed: 0, grid: grid}, fn _, acc ->
      {flashed, grid} = do_round(acc.grid)

      %{acc | flashed: acc.flashed + flashed, grid: grid}
    end)
  end

  @doc """
  Perform any number of rounds until the criteria is met

  `do_rounds_until` encodes the termination criteria directly; Part Two ends
  when all of the dumbo octopuses flashed at once (i.e. `flash_count == 100`)
  """
  def part_two(grid) do
    do_rounds_until(grid)
  end

  defp do_rounds_until(grid, idx \\ 1) do
    {flash_count, grid} = do_round(grid)

    if flash_count == 100 do
      idx
    else
      do_rounds_until(grid, idx + 1)
    end
  end

  def do_round(grid) do
    grid =
      grid
      |> map_vals(&inc/1)
      |> apply_flash()

    flash_count =
      grid
      |> Enum.filter(&flashing?/1)
      |> length()

    final = map_vals(grid, fn v -> if v > 9, do: 0, else: v end)

    {flash_count, final}
  end

  def map_vals(m, f) do
    Map.new(m, fn {k, v} -> {k, f.(v)} end)
  end

  def inc(x), do: x + 1

  defp flashing?({_k, v}), do: v > 9

  defp apply_flash(grid) do
    flashing =
      grid
      |> Enum.filter(&flashing?/1)
      |> Enum.map(&elem(&1, 0))

    apply_flash_recur(grid, flashing, MapSet.new())
  end

  defp apply_flash_recur(grid, [], _applied), do: grid

  defp apply_flash_recur(grid, [hd | _rest], applied) do
    new_grid =
      hd
      |> neighbors()
      |> Enum.reduce(grid, fn pos, grid ->
        Map.update!(grid, pos, &(&1 + 1))
      end)

    applied = MapSet.put(applied, hd)

    new_flashing =
      new_grid
      |> Enum.filter(&flashing?/1)
      |> Enum.map(&elem(&1, 0))
      |> Enum.reject(&MapSet.member?(applied, &1))

    apply_flash_recur(new_grid, new_flashing, applied)
  end

  defp neighbors({x, y} = self) do
    ns =
      for x0 <- (x - 1)..(x + 1),
          y0 <- (y - 1)..(y + 1),
          x0 >= 0 and x0 < 10 and y0 >= 0 and y0 < 10 do
        {x0, y0}
      end

    ns -- [self]
  end
end
