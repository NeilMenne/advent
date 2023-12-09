defmodule Day08Test do
  use ExUnit.Case

  alias Advent2023.Day08

  @sample_input "data/input08_test.txt"
  @sample_input_2 "data/input08_test.2.txt"

  test "part1" do
    ans = @sample_input |> Day08.process_input() |> Day08.part1()
    assert ans == 6
  end

  test "part2" do
    ans = @sample_input_2 |> Day08.process_input() |> Day08.part2()
    assert ans == 6
  end
end
