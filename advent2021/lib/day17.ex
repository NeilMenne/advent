defmodule Day17 do
  @test_input %{xs: 20..30, ys: -10..-5}
  @input %{xs: 14..50, ys: -267..-225}

  def test_input, do: @test_input
  def input, do: @input

  def part_one(%{ys: ys}) do
    min_y = Enum.min(ys)

    round(min_y * (min_y + 1) / 2)
  end

  def part_two(target) do
    max_x = Enum.max(target.xs)
    min_y = Enum.min(target.ys)
    max_y = abs(min_y)

    for x_vel <- 0..max_x, y_vel <- min_y..max_y do
      do_trial(x_vel, y_vel, target)
    end
    |> Enum.reject(&(&1 == :miss))
    |> length()
  end

  def do_trial(x_vel, y_vel, target) do
    do_trial(%{x: 0, y: 0, x_vel: x_vel, y_vel: y_vel}, target)
  end

  def do_trial(probe, target) do
    probe = do_step(probe)

    cond do
      in_target?(probe, target) -> :hit
      short?(probe, target) -> :miss
      long?(probe, target) -> :miss
      beyond_target?(probe, target) -> :miss
      true -> do_trial(probe, target)
    end
  end

  defp in_target?(%{x: x, y: y}, %{xs: xs, ys: ys}), do: x in xs and y in ys

  defp short?(%{x: x, x_vel: x_vel}, %{xs: xs}), do: x_vel == 0 and x not in xs

  defp long?(%{x: x}, %{xs: xs}), do: x > Enum.max(xs)

  defp beyond_target?(%{y: y}, %{ys: ys}), do: y < Enum.min(ys)

  defp do_step(probe) do
    probe
    |> Map.update!(:x, &(&1 + probe.x_vel))
    |> Map.update!(:y, &(&1 + probe.y_vel))
    |> Map.update!(:x_vel, &with_drag/1)
    |> Map.update!(:y_vel, &with_grav/1)
  end

  defp with_drag(0), do: 0
  defp with_drag(x_vel) when x_vel > 0, do: x_vel - 1
  defp with_drag(x_vel) when x_vel < 0, do: x_vel + 1

  defp with_grav(y_vel), do: y_vel - 1
end
