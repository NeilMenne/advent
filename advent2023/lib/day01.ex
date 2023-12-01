defmodule Advent2023.Day01 do
  def process_input(file_loc) do
    file_loc
    |> File.stream!()
    |> Enum.map(&String.trim_trailing/1)
  end

  @doc """
  On each line, the calibration value can be found by combining the first digit
  and the last digit (in that order) to form a single two-digit number.
  """
  def part1(input) do
    input
    |> Enum.map(&extract_digits/1)
    # unique to part 1, since some lines don't contain digits
    |> Enum.reject(&(length(&1) == 0))
    |> Enum.map(fn l ->
      h = List.first(l)
      t = List.last(l)

      String.to_integer(h <> t)
    end)
    |> Enum.sum()
  end

  defp extract_digits(str) do
    Regex.scan(~r/\d/, str)
    |> List.flatten()
  end

  @doc """
  Your calculation isn't quite right. It looks like some of the digits are
  actually spelled out with letters: one, two, three, four, five, six, seven,
  eight, and nine also count as valid "digits".
  """
  def part2(input) do
    input
    |> Enum.map(&extract_digits_pt2/1)
    |> Enum.map(fn [h, t] ->
      10 * h + t
    end)
    |> Enum.sum()
  end

  @first_pattern ~r/\d|one|two|three|four|five|six|seven|eight|nine/
  @last_pattern ~r/\d|enin|thgie|neves|xis|evif|ruof|eerht|owt|eno/

  defp extract_digits_pt2(str) do
    first =
      Regex.run(@first_pattern, str)
      |> List.first()
      |> to_dig()

    last =
      str
      |> String.reverse()
      |> then(fn rev -> Regex.run(@last_pattern, rev) end)
      |> List.first()
      |> String.reverse()
      |> to_dig()

    [first, last]
  end

  defp to_dig(str) do
    case str do
      "one" -> 1
      "two" -> 2
      "three" -> 3
      "four" -> 4
      "five" -> 5
      "six" -> 6
      "seven" -> 7
      "eight" -> 8
      "nine" -> 9
      _ -> String.to_integer(str)
    end
  end
end
