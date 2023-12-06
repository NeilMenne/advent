defmodule Day06Test do
  use ExUnit.Case

  alias Advent2023.Day06

  @sample_input "data/input06_test.txt"

  test "part1" do
    ans = @sample_input |> Day06.process_input() |> Day06.part1()
    assert ans == 288
  end

  test "part2" do
    ans = @sample_input |> Day06.process_input() |> Day06.part2()
    assert ans == 71503
  end
end
