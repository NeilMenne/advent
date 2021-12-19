defmodule Day18 do
  @moduledoc "do snailfish math"

  def process_input(filename) do
    File.read!(filename)
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
  end

  defp parse_line(string) do
    string
    |> String.codepoints()
    |> Enum.reduce(%{depth: -1, vals: []}, fn
      "[", acc -> %{acc | depth: acc.depth + 1}
      "]", acc -> %{acc | depth: acc.depth - 1}
      ",", acc -> acc
      n, acc -> %{acc | vals: [{acc.depth, String.to_integer(n)} | acc.vals]}
    end)
    |> Map.fetch!(:vals)
    |> Enum.reverse()
  end

  @doc """
  Add up all of the snailfish numbers from the homework assignment in the order
  they appear. What is the magnitude of the final sum?
  """
  def part_one(inputs) do
    inputs
    |> Enum.reduce(&add(&2, &1))
    |> magnitude()
  end

  @doc """
  What is the largest magnitude you can get from adding only two of the
  snailfish numbers?

  Since snailfish math is not commutative, we need to try both `a + b` and `b + a`
  """
  def part_two(inputs) do
    for l <- inputs, r <- inputs, l != r do
      add(l, r)
      |> magnitude()
    end
    |> Enum.max()
  end

  def add(l, r) do
    join(l, r)
    |> reduce()
  end

  defp reduce(joined) do
    cond do
      explode?(joined) -> explode(joined) |> reduce()
      split?(joined) -> split(joined) |> reduce()
      true -> joined
    end
  end

  def explode?(list), do: Enum.any?(list, &(depth(&1) >= 4))

  def split?(list), do: Enum.any?(list, &(value(&1) > 9))

  defp depth({d, _}), do: d

  defp value({_, v}), do: v

  defp join(l, r), do: Enum.map(l ++ r, fn {depth, val} -> {depth + 1, val} end)

  defp explode(joined) do
    {left, [frst, scnd | right]} = Enum.split_while(joined, &(depth(&1) < 4))

    d = depth(frst) - 1

    merge_left(frst, left) ++ [{d, 0}] ++ merge_right(scnd, right)
  end

  defp merge_left(_frst, []), do: []

  defp merge_left({_d, val}, left) do
    idx = length(left) - 1

    List.update_at(left, idx, fn {d, v} -> {d, v + val} end)
  end

  defp merge_right(_scnd, []), do: []

  defp merge_right({_, val}, [{d, v} | rest]) do
    [{d, v + val} | rest]
  end

  defp split(joined) do
    {left, [{d, val} | rest]} = Enum.split_while(joined, &(value(&1) <= 9))

    lv = floor(val / 2)
    rv = ceil(val / 2)

    pair = [{d + 1, lv}, {d + 1, rv}]

    left ++ pair ++ rest
  end

  @doc """
  since we created an adjacency list to make specifically explode easier, our
  algorithm for `magnitude` is a bit more imperative. we replace the deepest
  pair with a single node representing their sum (according to the rules for
  magnitude) and recursively call `magnitude/1` with the smaller list.
  terminating when there's only two root node level values left

  in the event of a tie, this works on the first pair since all pairs at a given
  deepest level will still be adjacent
  """
  def magnitude([{0, l}, {0, r}]), do: 3 * l + 2 * r

  def magnitude(list) do
    max_depth = list |> Enum.map(&depth/1) |> Enum.max()

    # identifies left neighbor
    idx = Enum.find_index(list, &(depth(&1) == max_depth))

    # removes right neighbor
    {{_, rv}, list} = List.pop_at(list, idx + 1)

    # replace left neighbor with sum and raise its depth
    list
    |> List.update_at(idx, fn {d, lv} ->
      {d - 1, 3 * lv + 2 * rv}
    end)
    |> magnitude()
  end
end
