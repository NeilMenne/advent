defmodule Day24 do
  @moduledoc false

  def process_input(filename) do
    filename
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.map(&to_instruction/1)
  end

  def to_instruction(str) do
    case String.split(str) do
      ["inp", reg] -> {:inp, String.to_atom(reg)}
      ["add", reg, right] -> {:+, String.to_atom(reg), atom_or_num(right)}
      ["mul", reg, right] -> {:*, String.to_atom(reg), atom_or_num(right)}
      ["div", reg, right] -> {:div, String.to_atom(reg), atom_or_num(right)}
      ["mod", reg, right] -> {:rem, String.to_atom(reg), atom_or_num(right)}
      ["eql", reg, right] -> {:eql, String.to_atom(reg), atom_or_num(right)}
    end
  end

  def eql(x, y) do
    if x == y, do: 1, else: 0
  end

  defp atom_or_num(s) do
    case Integer.parse(s) do
      {i, _} -> i
      :error -> String.to_atom(s)
    end
  end

  def part_one(instructions) do
    Enum.chunk_every(instructions, 18)
    |> Enum.with_index()
    |> find_max()
  end

  def part_two(instructions) do
    Enum.chunk_every(instructions, 18)
    |> Enum.with_index()
    |> find_min()
  end

  def find_max(digit_instrs) do
    max_arr = for _ <- 0..13, do: 0

    find_extrema(digit_instrs, max_arr, [], &max_delta_fn/4)
  end

  def find_min(digit_instrs) do
    min_arr = for _ <- 0..13, do: 0

    find_extrema(digit_instrs, min_arr, [], &min_delta_fn/4)
  end

  # if `div z 1`, push {jdx, {val_y}} onto the stack; `val_y` comes from 16th instr
  #
  # if `div z 26`, pop {jdx, {val_y}} from the stack, `delta = {val_y} +
  # {val_x}`; `val_x` comes from the 6th instr.
  #   a. if `delta` is negative, `arr[idx] = arr[jdx] + delta`; otherwise,
  #      `arr[jdx] = arr[idx] - delta`
  #   b. to maximize, let arr[jdx] be 9 or arr[idx] be 9 respectively
  #   c. to minimize, let arr[idx] be 1 or arr[jdx] be 1 respectively
  #
  # Since there are an equal number of push and pop subroutines (with varying
  # values for `val_x` and `val_y`); what we're actually doing is relating two
  # digits to each other; if `delta` is exactly 0, both digits will always
  # be the same.
  defp find_extrema([], arr, _stack, _arr_fn), do: Integer.undigits(arr)

  defp find_extrema([{instrs, idx} | rest], arr, stack, arr_fn) do
    if Enum.find(instrs, &match?({:div, :z, 26}, &1)) do
      [{jdx, y} | new_stack] = stack

      {_, :x, x} = Enum.at(instrs, 5)

      delta = y + x

      arr = arr_fn.(arr, idx, jdx, delta)

      find_extrema(rest, arr, new_stack, arr_fn)
    else
      {_, :y, y} = Enum.at(instrs, 15)

      find_extrema(rest, arr, [{idx, y} | stack], arr_fn)
    end
  end

  defp max_delta_fn(arr, idx, jdx, delta) when delta < 0 do
    arr
    |> List.replace_at(jdx, 9)
    |> List.replace_at(idx, 9 + delta)
  end

  defp max_delta_fn(arr, idx, jdx, delta) do
    arr
    |> List.replace_at(idx, 9)
    |> List.replace_at(jdx, 9 - delta)
  end

  defp min_delta_fn(arr, idx, jdx, delta) when delta < 0 do
    arr
    |> List.replace_at(idx, 1)
    |> List.replace_at(jdx, 1 - delta)
  end

  defp min_delta_fn(arr, idx, jdx, delta) do
    arr
    |> List.replace_at(jdx, 1)
    |> List.replace_at(idx, 1 + delta)
  end

  def brute_force(range, instructions) do
    range
    |> Stream.reject(&(0 in Integer.digits(&1)))
    |> Stream.map(&{&1, run_program(&1, instructions)})
    |> Enum.find(&match?({_ans, %{reg: %{z: 0}}}, &1))
  end

  def run_program(guess, instructions) do
    inputs = guess |> Integer.digits()

    Enum.reduce(
      instructions,
      %{inputs: inputs, reg: %{w: 0, x: 0, y: 0, z: 0}},
      &process_instruction/2
    )
  end

  defp process_instruction({:inp, dest}, %{inputs: [i | rest]} = state) do
    state
    |> put_in([:reg, dest], i)
    |> Map.put(:inputs, rest)
  end

  defp process_instruction({fun, l, r}, state) when is_number(r) do
    mod = if fun == :eql, do: __MODULE__, else: Kernel

    update_in(state, [:reg, l], &apply(mod, fun, [&1, r]))
  end

  defp process_instruction({fun, l, r}, state) do
    mod = if fun == :eql, do: __MODULE__, else: Kernel

    update_in(state, [:reg, l], &apply(mod, fun, [&1, get_in(state, [:reg, r])]))
  end
end
