defmodule Day02 do
  @moduledoc false

  @test_input "data/day02_test.txt"

  @input "data/day02.txt"

  def test_input, do: @test_input |> File.stream!() |> Enum.map(&process_command/1)

  def input, do: @input |> File.stream!() |> Enum.map(&process_command/1)

  @known_commands [:forward, :down, :up]
  def known_commands, do: @known_commands

  defp process_command(str) do
    [command, dist] =
      str
      |> String.trim_trailing()
      |> String.split()

    {String.to_existing_atom(command), String.to_integer(dist)}
  end

  @doc """
  Calculate the horizontal position and depth you would have after following the
  planned course. What do you get if you multiply your final horizontal position
  by your final depth?
  """
  def part_one(input_commands) do
    %{horiz: x, vert: y} =
      Enum.reduce(
        input_commands,
        %{horiz: 0, vert: 0},
        &update_pos/2
      )

    x * y
  end

  defp update_pos({:forward, x_off}, acc), do: %{acc | horiz: acc.horiz + x_off}
  defp update_pos({:up, y_off}, acc), do: %{acc | vert: acc.vert - y_off}
  defp update_pos({:down, y_off}, acc), do: %{acc | vert: acc.vert + y_off}

  @doc """

  """
  def part_two(input_commands) do
    %{horiz: x, vert: y} =
      Enum.reduce(
        input_commands,
        %{horiz: 0, vert: 0, aim: 0},
        &update_aim/2
      )

    x * y
  end

  defp update_aim({:up, a_off}, acc), do: %{acc | aim: acc.aim - a_off}
  defp update_aim({:down, a_off}, acc), do: %{acc | aim: acc.aim + a_off}

  defp update_aim({:forward, x_off}, acc) do
    %{acc | horiz: acc.horiz + x_off, vert: acc.vert + x_off * acc.aim}
  end
end
