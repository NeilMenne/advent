defmodule Day25 do
  @moduledoc false

  def process_input(filename) do
    filename
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.map(&String.codepoints/1)
    |> to_grid()
  end

  defp to_grid([l | _] = lines) do
    width = length(l) - 1
    height = length(lines) - 1

    for h <- 0..height, w <- 0..width do
      type =
        case get_in(lines, [Access.at(h), Access.at(w)]) do
          "v" -> :south
          ">" -> :east
          _ -> nil
        end

      {{h, w}, type}
    end
    |> Enum.reject(&match?({_, nil}, &1))
    |> Enum.reduce(%{south: MapSet.new(), east: MapSet.new()}, fn {pos, type}, acc ->
      Map.update!(acc, type, &MapSet.put(&1, pos))
    end)
    |> Map.put(:size, {height, width})
  end

  def part_one(state) do
    do_steps_recur(state, 1)
  end

  defp do_steps_recur(state, step_num) do
    next = do_step(state)

    if MapSet.equal?(state.south, next.south) and MapSet.equal?(state.east, next.east) do
      step_num
    else
      do_steps_recur(next, step_num + 1)
    end
  end

  @doc """
  1. Calculate the moves for _both_ east and south
  2. East moves
  3. South moves iff their new locations are still available
  """
  def do_step(state) do
    east_moves =
      state.east
      |> Enum.reduce(MapSet.new(), fn pos, acc ->
        next = next_pos(:east, pos, state.size)

        if MapSet.member?(state.south, next) or MapSet.member?(state.east, next) do
          MapSet.put(acc, pos)
        else
          MapSet.put(acc, next)
        end
      end)

    south_moves =
      state.south
      |> Enum.reduce(MapSet.new(), fn pos, acc ->
        next = next_pos(:south, pos, state.size)

        if MapSet.member?(state.south, next) or MapSet.member?(east_moves, next) do
          MapSet.put(acc, pos)
        else
          MapSet.put(acc, next)
        end
      end)

    %{state | east: east_moves, south: south_moves}
  end

  def next_pos(:south, {h, w}, {max_h, _}) do
    next = h + 1

    if next > max_h, do: {0, w}, else: {next, w}
  end

  def next_pos(:east, {h, w}, {_, max_w}) do
    next = w + 1

    if next > max_w, do: {h, 0}, else: {h, next}
  end
end
