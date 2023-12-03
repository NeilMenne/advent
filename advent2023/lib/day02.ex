defmodule Advent2023.Day02 do
  def process_input(file_loc) do
    file_loc
    |> File.stream!()
    |> Enum.map(&String.trim_trailing/1)
    |> Enum.map(&parse_line/1)
  end

  defp parse_line(line) do
    regex = ~r/Game (\d+): (.+?)$/

    [_str, id_str, pulls_str] = Regex.run(regex, line)

    %{id: String.to_integer(id_str), pulls: parse_pulls(pulls_str)}
  end

  defp parse_pulls(pulls_str) do
    pull_regex = ~r/(\d+) (\w+),?/

    pulls_str
    |> String.split(";")
    |> Enum.map(fn pull ->
      pulls = Regex.scan(pull_regex, pull)

      Map.new(pulls, fn [_, count_str, color] ->
        count = String.to_integer(count_str)
        {String.to_atom(color), count}
      end)
    end)
  end

  @doc """
  The Elf would first like to know which games would have been possible if the
  bag contained only 12 red cubes, 13 green cubes, and 14 blue cubes?

  What is the sum of the IDs of those games?
  """
  def part1(games) do
    games
    |> Enum.reject(fn %{pulls: pulls} ->
      Enum.any?(pulls, fn pull ->
        Map.get(pull, :red, 0) > 12 or Map.get(pull, :green, 0) > 13 or
          Map.get(pull, :blue, 0) > 14
      end)
    end)
    |> Enum.map(& &1.id)
    |> Enum.sum()
  end

  @doc """
  As you continue your walk, the Elf poses a second question: in each game you
  played, what is the fewest number of cubes of each color that could have been
  in the bag to make the game possible?

  The power of a set of cubes is equal to the numbers of red, green, and blue
  cubes multiplied together.
  """
  def part2(games) do
    games
    |> Enum.map(fn %{pulls: pulls} ->
      min_blue = pulls |> Enum.map(&Map.get(&1, :blue, 0)) |> Enum.max()
      min_red = pulls |> Enum.map(&Map.get(&1, :red, 0)) |> Enum.max()
      min_green = pulls |> Enum.map(&Map.get(&1, :green, 0)) |> Enum.max()

      min_blue * min_red * min_green
    end)
    |> Enum.sum()
  end
end
