defmodule Day07Test do
  use ExUnit.Case

  alias Advent2023.Day07

  @sample_input "data/input07_test.txt"

  test "part1" do
    ans = @sample_input |> Day07.process_input() |> Day07.part1()
    assert ans == 6440
  end

  test "part2" do
    ans = @sample_input |> Day07.process_input() |> Day07.part2()
    assert ans == 5905
  end
end
