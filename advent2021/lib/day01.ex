defmodule Day01 do
  @moduledoc false

  @test_input "data/day01_test.txt"

  @input "data/day01.txt"

  def test_input, do: @test_input |> File.stream!() |> Enum.map(&to_int/1)

  def input, do: @input |> File.stream!() |> Enum.map(&to_int/1)

  defp to_int(str) do
    str
    |> String.replace("\n", "")
    |> String.to_integer()
  end

  @doc """
  Counts the number of times a depth measurement increases from the previous measurement
  """
  def part_one(measurements) do
    measurements
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.filter(fn [x, y] -> x < y end)
    |> Enum.count()
  end

  @doc """
  Count the number of times the sum of measurements in this sliding window increases
  """
  def part_two(measurements) do
    measurements
    |> Enum.chunk_every(3, 1, :discard)
    |> Enum.map(&Enum.sum/1)
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.filter(fn [x, y] -> x < y end)
    |> Enum.count()
  end
end
