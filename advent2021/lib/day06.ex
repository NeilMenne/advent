defmodule Day06 do
  @moduledoc false

  @doc """
  The input can be modeled as a frequency map counting the number of fish with a
  set number of days until they spawn new lanternfish.
  """
  def process_input(filename) do
    File.read!(filename)
    |> String.trim_trailing()
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
    |> Enum.frequencies()
  end

  @doc """
  Find a way to simulate lanternfish. How many lanternfish would there be after X days?

  Part 1: Simulate for 80 days
  Part 2: Simulate for 256 days

  Parts 1 and 2 both hinge on the same functionality, but merely change the
  number of days you have to model. Thanks to the concise format afforded by
  the map-to-map inner loop, the solution does not require performance tuning or
  _any_ alteration to scale to support P2
  """
  def solve(lanternfish_map, 0) do
    lanternfish_map
    |> Map.values()
    |> Enum.sum()
  end

  def solve(lanternfish_map, days) do
    decremented =
      Map.new(lanternfish_map, fn {k, v} ->
        {k - 1, v}
      end)

    {to_make, map} = Map.pop(decremented, -1, 0)

    lanternfish_map =
      map
      |> Map.put(8, to_make)
      |> Map.update(6, to_make, &(&1 + to_make))

    solve(lanternfish_map, days - 1)
  end
end
