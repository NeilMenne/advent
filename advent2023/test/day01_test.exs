defmodule Day01Test do
  use ExUnit.Case

  alias Advent2023.Day01

  @sample_input "data/input01_test.txt"
  @sample_input_2 "data/input01_test.2.txt"

  test "part1" do
    ans = @sample_input |> Day01.process_input() |> Day01.part1()
    assert ans == 142
  end

  test "part2" do
    ans = @sample_input_2 |> Day01.process_input() |> Day01.part2()

    assert ans == 281
  end
end
