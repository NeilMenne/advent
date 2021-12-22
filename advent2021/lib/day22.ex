defmodule Day22 do
  @moduledoc false

  def process_input(filename) do
    filename
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.map(&to_instruction/1)
  end

  defp to_instruction(str) do
    [instr, xr, yr, zr] =
      Regex.run(~r/(on|off) x=(.+?),y=(.+?),z=(.+?)$/, str, capture: :all_but_first)

    {String.to_atom(instr), [to_range(xr), to_range(yr), to_range(zr)]}
  end

  defp to_range(str), do: Code.eval_string(str) |> elem(0)

  @p1_range [-50..50, -50..50, -50..50]

  @doc """
  Considering only the instructions in the target area, defined as `@p1_range`,
  how many 1x1x1 cubes are on.

  While a naive method was sufficient for this part, it was refactored to use
  the P2 compatible version.
  """
  def part_one(instructions) do
    instructions
    |> Enum.reject(fn {_op, rs} -> disjoint?(rs, @p1_range) end)
    |> apply_instructions()
  end

  defp disjoint?(c1, c2) do
    Enum.zip(c1, c2)
    |> Enum.any?(fn {a, b} -> Range.disjoint?(a, b) end)
  end

  @doc """
  Consider all instructions, how many cubes are on
  """
  def part_two(instructions) do
    instructions
    |> apply_instructions()
  end

  @doc """
  create the maximally sized cubes for both on and off instructions; by always
  growing them both, unused parts of the off ranges are then preserved on both
  sides of the subtraction operation
  """
  def apply_instructions(instructions) do
    %{on: ons, off: offs} =
      Enum.reduce(instructions, %{on: [], off: []}, fn {cmd, c}, acc ->
        ons = adjust_cubes(acc.off, c, cmd, :on)
        offs = adjust_cubes(acc.on, c, cmd, :off)

        %{acc | on: acc.on ++ ons, off: acc.off ++ offs}
      end)

    volume(ons) - volume(offs)
  end

  defp adjust_cubes(offs, new, :on, :on) do
    [new | with_new(offs, new)]
  end

  defp adjust_cubes(input, new, _curr, _cmd) do
    with_new(input, new)
  end

  defp with_new([], _), do: []

  defp with_new(cs, c) do
    cs
    |> Enum.map(&merge_ranges(&1, c))
    |> Enum.reject(&(length(&1) < 3))
  end

  defp merge_ranges([], []), do: []

  defp merge_ranges([lx..ly | ls], [rx..ry | rs]) do
    newl = max(lx, rx)
    newr = min(ly, ry)

    # do not keep ranges that go backwards
    if newl > newr do
      []
    else
      [newl..newr | merge_ranges(ls, rs)]
    end
  end

  def volume(cubes) do
    Enum.reduce(cubes, 0, fn dims, acc ->
      volume =
        dims
        |> Enum.map(&Range.size/1)
        |> Enum.product()

      acc + volume
    end)
  end
end
