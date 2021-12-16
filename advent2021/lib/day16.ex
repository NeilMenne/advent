defmodule Day16 do
  @moduledoc false

  def input_data(filename) do
    File.read!(filename)
    |> String.trim_trailing()
  end

  def parse(str) do
    str
    |> Base.decode16!()
    |> to_structured_data()
    |> elem(0)
  end

  defp to_structured_data(<<v::3, 4::3, rest::bits>>) do
    {val, tail} = to_literal(rest)

    {%{version: v, type: 4, val: val}, to_structured_data(tail)}
  end

  defp to_structured_data(<<v::3, t::3, 0::1, l::15, rest::bits-size(l), tail::bits>>) do
    vals = process_vals(rest)
    {%{version: v, type: t, val: vals}, tail}
  end

  defp to_structured_data(<<v::3, t::3, 1::1, n::11, tail::bits>>) do
    {tail, vals} =
      Enum.reduce(1..n, {tail, []}, fn _, {tail, acc} ->
        {val, tail} = to_structured_data(tail)

        {tail, [val | acc]}
      end)

    {%{version: v, type: t, val: Enum.reverse(vals)}, tail}
  end

  defp to_structured_data(rest), do: rest

  defp process_vals(rest), do: process_vals(rest, [])

  defp process_vals(rest, acc) do
    case to_structured_data(rest) do
      {val, rest} -> process_vals(rest, [val | acc])
      _ -> Enum.reverse(acc)
    end
  end

  defp to_literal(bstring), do: to_literal(bstring, <<>>)
  defp to_literal(<<0::1, n::4, rest::bits>>, acc), do: {to_int(<<acc::bits, n::4>>), rest}
  defp to_literal(<<1::1, n::4, rest::bits>>, acc), do: to_literal(rest, <<acc::bits, n::4>>)

  defp to_int(bstring) do
    bsize = bit_size(bstring)

    <<int::size(bsize)>> = bstring
    int
  end

  @doc """
  Walk the tree and accumulate version numbers
  """
  def part_one(str), do: str |> parse() |> calc_version()

  defp calc_version(%{type: 4, version: ver}), do: ver

  defp calc_version(%{type: _, version: ver, val: vals}) do
    sum =
      vals
      |> Enum.map(&calc_version/1)
      |> Enum.sum()

    sum + ver
  end

  @doc """
  Evaluate the tree
  """
  def part_two(str), do: str |> parse() |> eval()

  defp eval(%{type: 0, val: vals}), do: vals |> Enum.map(&eval/1) |> Enum.sum()
  defp eval(%{type: 1, val: vals}), do: vals |> Enum.map(&eval/1) |> Enum.product()
  defp eval(%{type: 2, val: vals}), do: vals |> Enum.map(&eval/1) |> Enum.min()
  defp eval(%{type: 3, val: vals}), do: vals |> Enum.map(&eval/1) |> Enum.max()

  defp eval(%{type: 4, val: x}), do: x

  defp eval(%{type: t, val: vals}) do
    [x, y] = Enum.map(vals, &eval/1)

    cond do
      t == 5 -> if x > y, do: 1, else: 0
      t == 6 -> if x < y, do: 1, else: 0
      t == 7 -> if x == y, do: 1, else: 0
    end
  end
end
