defmodule Advent2023.Day04 do
  def process_input(file_loc) do
    file_loc
    |> File.stream!()
    |> Enum.map(&String.trim_trailing/1)
    |> Enum.map(&parse_line/1)
  end

  defp parse_line(line) do
    regex = ~r/Card *(\d+):/

    [_, id] = Regex.run(regex, line)

    [num_str, win_str] =
      line
      |> String.replace(regex, "")
      |> String.split("|")

    nset =
      num_str
      |> String.split()
      |> MapSet.new()

    wset =
      win_str
      |> String.split()
      |> MapSet.new()

    %{
      id: String.to_integer(id),
      wins: nset |> MapSet.intersection(wset) |> MapSet.size()
    }
  end

  @doc """
  As far as the Elf has been able to figure out, you have to figure out which of
  the numbers you have appear in the list of winning numbers. The first match
  makes the card worth one point and each match after the first doubles the
  point value of that card.
  """
  def part1(cards) do
    Enum.reduce(cards, 0, fn %{wins: w}, acc ->
      if w > 0 do
        acc + round(:math.pow(2, w - 1))
      else
        acc
      end
    end)
  end

  @doc """
  Process all of the original and copied scratchcards until no more scratchcards
  are won. Including the original set of scratchcards, how many total
  scratchcards do you end up with?

  NOTE: copies of scratchcards are scored like normal scratchcards and have the
  same card number as the card they copied
  """
  def part2(cards) do
    Enum.reduce(cards, %{}, fn %{id: id, wins: w}, acc ->
      acc
      |> Map.put_new(id, 1)
      |> with_multiples(id, w)
    end)
    |> Map.values()
    |> Enum.sum()
  end

  def with_multiples(m, _id, 0), do: m

  def with_multiples(m, id, n) do
    curr = Map.fetch!(m, id)

    (id + 1)..(id + n)
    |> Enum.reduce(m, fn i, acc ->
      Map.update(acc, i, 1 + curr, &(&1 + curr))
    end)
  end
end
