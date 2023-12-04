defmodule Day04Test do
  use ExUnit.Case

  alias Advent2023.Day04

  @sample_input "data/input04_test.txt"

  test "part1" do
    ans = @sample_input |> Day04.process_input() |> Day04.part1()
    assert ans == 13
  end

  test "part2" do
    ans = @sample_input |> Day04.process_input() |> Day04.part2()
    assert ans == 30
  end
end
