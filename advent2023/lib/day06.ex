defmodule Advent2023.Day06 do
  def process_input(file_loc) do
    [time, recs] =
      file_loc
      |> File.read!()
      |> String.trim_trailing()
      |> String.split("\n")
      |> Enum.map(fn line ->
        [_ | nums] = String.split(line)

        Enum.map(nums, &String.to_integer/1)
      end)

    %{times: time, records: recs}
  end

  @doc """
  Determine the number of ways you could beat the record in each race. What do
  you get if you multiply these numbers together?

  Your toy boat has a starting speed of zero millimeters per millisecond. For
  each whole millisecond you spend at the beginning of the race holding down the
  button, the boat's speed increases by one millimeter per millisecond.
  """
  def part1(%{times: ts, records: rs}) do
    ts
    |> Enum.zip(rs)
    |> Enum.map(fn {t, r} -> calculate(t, r) end)
    |> Enum.product()
  end

  @doc """
  Original brute force method developed for part 1
  """
  def simulate({time, record}) do
    0..time
    |> Enum.map(fn charge -> charge * (time - charge) end)
    |> Enum.reject(fn dist -> dist <= record end)
  end

  def part2(%{times: ts, records: rs}) do
    time =
      ts
      |> Enum.map(&to_string/1)
      |> Enum.join()
      |> String.to_integer()

    record =
      rs
      |> Enum.map(&to_string/1)
      |> Enum.join()
      |> String.to_integer()

    calculate(time, record)
  end

  # distance = (time - charge) * charge
  # distance = (time * charge) - charge^2
  # charge^2 - (time * charge) - distance = 0
  #
  # Using the quadratic formula for charge:
  # charge = (time +/- sqrt(time^2 - 4*dist)) / 2
  def calculate(time, record) do
    t2 = :math.pow(time, 2)

    # since we need an integer distance _greater_ than `record`
    d = record + 1

    c1 = (time + :math.sqrt(t2 - 4 * d)) / 2
    c2 = (time - :math.sqrt(t2 - 4 * d)) / 2

    floor(c1) - ceil(c2) + 1
  end
end
