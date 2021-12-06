defmodule Day05 do
  @moduledoc false

  def file_to_segments(filename) do
    File.stream!(filename)
    |> Enum.map(&String.trim_trailing/1)
    |> Enum.map(&to_segment/1)
  end

  defp to_segment(str) do
    m = Regex.named_captures(~r/(?<x1>\d+),(?<y1>\d+) -> (?<x2>\d+),(?<y2>\d+)/, str)

    Map.new(m, fn {k, v} -> {String.to_atom(k), String.to_integer(v)} end)
  end

  @doc """
  Consider only horizontal and vertical lines. At how many points do at least
  two lines overlap?
  """
  def part_one(segments) do
    grid =
      segments
      |> Enum.filter(fn seg -> horiz?(seg) or vert?(seg) end)
      |> Enum.reduce(%{}, &add_segment/2)

    Map.values(grid)
    |> Enum.filter(&(&1 >= 2))
    |> Enum.count()
  end

  defp horiz?(%{x1: x1, x2: x2}), do: x1 == x2

  defp vert?(%{y1: y1, y2: y2}), do: y1 == y2

  defp add_segment(seg, grid) do
    points =
      if horiz?(seg) or vert?(seg) do
        gen_points(seg)
      else
        gen_diagonal(seg)
      end

    Enum.reduce(points, grid, fn point, grid ->
      Map.update(grid, point, 1, &inc/1)
    end)
  end

  defp gen_points(seg) do
    for x <- seg.x1..seg.x2,
        y <- seg.y1..seg.y2 do
      {x, y}
    end
  end

  defp gen_diagonal(seg) do
    Enum.zip(seg.x1..seg.x2, seg.y1..seg.y2)
  end

  defp inc(x), do: x + 1

  @doc """
  Consider all of the lines. At how many points do at least two lines overlap?
  """
  def part_two(segments) do
    grid = Enum.reduce(segments, %{}, &add_segment/2)

    Map.values(grid)
    |> Enum.filter(&(&1 >= 2))
    |> Enum.count()
  end
end
