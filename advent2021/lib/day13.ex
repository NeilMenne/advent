defmodule Day13 do
  @moduledoc false

  def process_input(filename) do
    [dots_str, fold_strs] =
      filename
      |> File.read!()
      |> String.split("\n\n")

    dots_arr = to_dots_arr(dots_str)

    %{dots: dots_arr, folds: to_folds_arr(fold_strs), size: compute_size(dots_arr)}
  end

  defp to_dots_arr(dots_str) do
    String.split(dots_str, "\n")
    |> Enum.map(fn str ->
      [x, y] = String.split(str, ",")

      {String.to_integer(x), String.to_integer(y)}
    end)
  end

  defp to_folds_arr(fold_str) do
    fold_str
    |> String.split("\n")
    |> Enum.filter(&String.starts_with?(&1, "fold"))
    |> Enum.map(fn str ->
      m = Regex.named_captures(~r/fold along (?<axis>[x|y])=(?<pos>\d+)/, str)

      %{axis: String.to_atom(m["axis"]), pos: String.to_integer(m["pos"])}
    end)
  end

  defp compute_size(dots_arr) do
    {x_max, _} = dots_arr |> Enum.max_by(fn {x, _} -> x end)
    {_, y_max} = dots_arr |> Enum.max_by(fn {_, y} -> y end)

    {x_max, y_max}
  end

  def part_one(input) do
    post_fold = do_fold(input, List.first(input.folds))

    length(post_fold.dots)
  end

  def part_two(input) do
    %{dots: ds, size: {x_max, y_max}} =
      Enum.reduce(input.folds, input, fn fold, acc ->
        do_fold(acc, fold)
      end)

    dotset = MapSet.new(ds)

    # Solution ends up being taller than it is wide, so make the y-axis the
    # outer loop essentially rotating the output for easier reading
    Enum.map(0..y_max, fn y ->
      for x <- 0..x_max do
        if MapSet.member?(dotset, {x, y}), do: "#", else: "."
      end
      |> Enum.join()
      |> Kernel.<>("\n")
    end)
    |> IO.puts()
  end

  defp do_fold(%{dots: dots} = state, %{axis: :y, pos: pos}) do
    dots_arr =
      Enum.map(dots, fn {x, y} = dot_pos ->
        if y > pos do
          {x, y - 2 * (y - pos)}
        else
          dot_pos
        end
      end)
      |> Enum.uniq()

    %{state | dots: dots_arr, size: compute_size(dots_arr)}
  end

  defp do_fold(%{dots: dots} = state, %{axis: :x, pos: pos}) do
    dots_arr =
      Enum.map(dots, fn {x, y} = dot_pos ->
        if x > pos do
          {x - 2 * (x - pos), y}
        else
          dot_pos
        end
      end)
      |> Enum.uniq()

    %{state | dots: dots_arr, size: compute_size(dots_arr)}
  end
end
