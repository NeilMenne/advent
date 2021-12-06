defmodule Day04 do
  @moduledoc false

  def process_input(filename) do
    stream = File.stream!(filename)

    numbers =
      stream
      |> Enum.take(1)
      |> List.first()
      |> input_numbers()

    boards =
      stream
      |> Stream.drop(1)
      |> Enum.chunk_every(6)
      |> Enum.map(&create_board/1)

    {numbers, boards}
  end

  defp input_numbers(number_str) do
    number_str
    |> String.trim_trailing()
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
  end

  defp create_board([_blank | row_strs]) do
    rows =
      Enum.map(row_strs, fn row_str ->
        row_str
        |> String.trim_trailing()
        |> String.split()
        |> Enum.map(&String.to_integer/1)
      end)

    cols =
      0..4
      |> Enum.map(fn col_idx ->
        MapSet.new(rows, &Enum.at(&1, col_idx))
      end)

    rows = Enum.map(rows, &MapSet.new/1)

    %{
      check: cols ++ rows,
      uniq: Enum.reduce(cols, MapSet.new(), &MapSet.union/2)
    }
  end

  @doc """
  The score of the winning board can now be calculated. Start by finding the sum
  of all unmarked numbers on that board...

  To guarantee victory against the giant squid, figure out which board will win
  first. What will your final score be if you choose that board?
  """
  def part_one(numbers, boards) do
    so_far =
      numbers
      |> Enum.take(4)
      |> MapSet.new()

    numbers
    |> Enum.with_index()
    |> Enum.drop(4)
    |> Enum.reduce_while(so_far, fn {next, idx}, so_far ->
      so_far = MapSet.put(so_far, next)

      boards
      |> Enum.filter(&check_board(&1, so_far))
      |> Enum.take(1)
      |> case do
        [] ->
          {:cont, so_far}

        [board] ->
          sum =
            MapSet.difference(board.uniq, so_far)
            |> Enum.sum()

          {:halt, {next * sum, idx}}
      end
    end)
  end

  defp check_board(board, so_far) do
    Enum.any?(board.check, &empty_diff?(&1, so_far))
  end

  defp empty_diff?(s1, s2) do
    MapSet.difference(s1, s2) == MapSet.new()
  end

  @doc """
  You aren't sure how many bingo boards a giant squid could play at once, so
  rather than waste time counting its arms, the safe thing to do is to figure
  out which board will win last and choose that one. That way, no matter which
  boards it picks, it will win for sure.

  Exploiting the shape of Part One, we choose to compute the score for each
  board by individually considering when it would be solved. Maximizing the
  index of all the results.
  """
  def part_two(numbers, boards) do
    boards
    |> Enum.map(&part_one(numbers, [&1]))
    |> Enum.max_by(fn {_score, idx} -> idx end)
  end
end
