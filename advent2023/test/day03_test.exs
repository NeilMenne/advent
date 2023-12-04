defmodule Day03Test do
  use ExUnit.Case

  alias Advent2023.Day03

  @sample_input "data/input03_test.txt"

  test "part1" do
    ans = @sample_input |> Day03.process_input() |> Day03.part1()
    assert ans == 4361
  end

  test "part2" do
    ans = @sample_input |> Day03.process_input() |> Day03.part2()
    assert ans == 467_835
  end
end
