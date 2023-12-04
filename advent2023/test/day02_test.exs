defmodule Day02Test do
  use ExUnit.Case

  alias Advent2023.Day02

  @sample_input "data/input02_test.txt"

  test "part1" do
    ans = @sample_input |> Day02.process_input() |> Day02.part1()
    assert ans == 8
  end

  test "part2" do
    ans = @sample_input |> Day02.process_input() |> Day02.part2()
    assert ans == 2286
  end
end
