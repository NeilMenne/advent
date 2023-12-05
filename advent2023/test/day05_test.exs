defmodule Day05Test do
  use ExUnit.Case

  alias Advent2023.Day05

  @sample_input "data/input05_test.txt"

  test "part1" do
    ans = @sample_input |> Day05.process_input() |> Day05.part1()
    assert ans == 35
  end

  test "part2" do
    ans = @sample_input |> Day05.process_input() |> Day05.part2()
    assert ans == 46
  end

  describe "split_range/2" do
    test "non-overlapping" do
      {[10..20], []} = Day05.split_range(10..20, %{src: 21..30, delta: 100})
    end

    test "subsumed" do
      {[], [110..120]} = Day05.split_range(10..20, %{src: 9..21, delta: 100})
    end

    test "open on the right" do
      {[10..12], [113..120]} = Day05.split_range(10..20, %{src: 13..21, delta: 100})
    end

    test "open on the left" do
      {[15..20], [110..114]} = Day05.split_range(10..20, %{src: 9..14, delta: 100})
    end

    test "open on both sides" do
      {[10..13, 17..20], [114..116]} = Day05.split_range(10..20, %{src: 14..16, delta: 100})
    end
  end
end
