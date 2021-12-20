defmodule Day19 do
  @moduledoc false

  def process_input(filename) do
    filename
    |> File.read!()
    |> String.split("\n\n", trim: true)
    |> Enum.map(&build_scanner/1)
  end

  defp build_scanner(str) do
    [scanner | positions] = String.split(str, "\n", trim: true)

    scanner_id =
      Regex.run(~r/.*scanner (\d+).*/, scanner)
      |> List.last()
      |> String.to_integer()

    position_list = Enum.map(positions, &to_triple/1)

    %{
      scanner_id: scanner_id,
      positions: position_list
    }
  end

  defp to_triple(str) do
    String.split(str, ",")
    |> Enum.map(&String.to_integer/1)
    |> List.to_tuple()
  end

  @doc """
  Since the output of the resolution code is quite unwieldy, we're just going to
  print out the answer to part one on our way to resolving part two.

  Part One: using the relative positions of the beacons to any given scanner,
  assemble the full map of beacons. How many beacons are there?

  Part Two: What is the largest Manhattan distance between any two scanners?

  NOTE: results take roughly 1.16 seconds
  """
  def resolve_day(scanners) do
    [scanner_0 | resolved] = solve(scanners)

    scanner_0 =
      scanner_0
      |> Map.update!(:positions, &MapSet.new/1)
      |> Map.put(:scanner_rel, %{0 => {0, 0, 0}})
      |> common_beacons(resolved)

    IO.puts("part_one: #{Enum.count(scanner_0.positions)}")

    scs = Map.values(scanner_0.scanner_rel)

    max_dist =
      for s0 <- scs, s1 <- scs, s0 != s1 do
        manhattan_dist(s0, s1)
      end
      |> Enum.max()

    IO.puts("part_two: #{max_dist}")
  end

  defp common_beacons(s0, []), do: s0

  defp common_beacons(s0, [nxt | todo]) do
    {nxt_rel, _bcns} = common_points(s0, nxt)

    s0 =
      s0
      |> Map.update!(:positions, &add_new(&1, nxt_rel, nxt.positions))
      |> put_in([:scanner_rel, nxt.scanner_id], nxt_rel)

    common_beacons(s0, todo)
  end

  # returns the beacons in common; the primary value of this function is
  # actually the key which is the position of the right scanner relative to the
  # left one
  defp common_points(left, right) do
    for p0 <- left.positions, p1 <- right.positions do
      {p0, dist(p1, p0)}
    end
    |> Enum.reduce(%{}, fn {point, dist}, m ->
      Map.update(m, dist, [point], &[point | &1])
    end)
    |> Enum.filter(fn {_k, v} -> length(v) > 1 end)
    |> List.first()
  end

  # collect all known beacons by adjusting the beacons' positions to be relative
  # to s0 instead
  defp add_new(scan_pos, other_rel, other_pos) do
    other_pos_set =
      other_pos
      |> Enum.map(&add_rel(other_rel, &1))
      |> MapSet.new()

    MapSet.union(scan_pos, other_pos_set)
  end

  defp add_rel({relx, rely, relz}, {x, y, z}), do: {relx + x, rely + y, relz + z}

  @doc """
  Searches for a single scanner that can be reoriented relative to the others;
  results are reversed, so that scanner 0 and the nearest scanners are processed
  first for final positioning
  """
  def solve([s0 | rest]), do: solve_recur([s0], rest)

  def solve_recur(oriented, []), do: Enum.reverse(oriented)

  def solve_recur(oriented, [un | rest]) do
    res =
      Enum.reduce_while(oriented, :not_found, fn curr, _acc ->
        case attempt_overlap(curr, un) do
          {:found, un} -> {:halt, {:found, un}}
          :not_found -> {:cont, :not_found}
        end
      end)

    case res do
      {:found, new} ->
        # scanner was successfully reoriented relative to one other scanner
        solve_recur([new | oriented], rest)

      :not_found ->
        unoriented = rest ++ [un]
        solve_recur(oriented, unoriented)
    end
  end

  # chooses the single permutation that generates the required number of
  # overlapping beacons for the target scanner `s1`. IF the permutation is
  # found, we don't note but instead return the permuted positions for later
  # efforts
  def attempt_overlap(s0, s1) do
    s1
    |> all_rotations()
    |> Enum.reduce_while(:not_found, fn {perm_idx, perm}, _acc ->
      if sufficient_overlap?(s0, perm) do
        found =
          s1
          |> Map.put(:positions, perm)
          |> Map.put(:perm_idx, perm_idx)
          |> Map.put(:rel, s0.scanner_id)

        {:halt, {:found, found}}
      else
        {:cont, :not_found}
      end
    end)
  end

  defp all_rotations(scanner) do
    permutations =
      scanner.positions
      |> Stream.map(&permute/1)

    Stream.map(0..23, fn idx -> {idx, Enum.map(permutations, &Enum.at(&1, idx))} end)
  end

  # NOTE: this compares an input scanner against a single rotation of the other
  defp sufficient_overlap?(s0, p1s) do
    for p0 <- s0.positions, p1 <- p1s do
      dist(p0, p1)
    end
    |> Enum.reduce(%{}, fn dist, m -> Map.update(m, dist, 1, &(&1 + 1)) end)
    |> Map.values()
    |> Enum.frequencies()
    |> Map.keys()
    |> Enum.any?(&(&1 >= 12))
  end

  defp manhattan_dist(p0, p1) do
    dist(p0, p1)
    |> Tuple.to_list()
    |> Enum.map(&abs/1)
    |> Enum.sum()
  end

  defp dist({x0, y0, z0}, {x1, y1, z1}) do
    {x1 - x0, y1 - y0, z1 - z0}
  end

  # NOTE: 0, 90, 180, 270 degrees respectively
  defp rotations({x, y, z} = orig) do
    [orig, {-y, x, z}, {-x, -y, z}, {y, -x, z}]
  end

  # NOTE: forward, backwards, right, left, up, and down respectively
  defp orientations({x, y, z} = frwd) do
    [frwd, {-x, y, -z}, {-z, y, x}, {z, y, -x}, {x, -z, y}, {x, z, -y}]
  end

  # NOTE: all permutations works by first providing all orientations and then
  # flat mapping the rotations; while a touch verbose, it was easier to debug
  defp permute(pos) do
    pos
    |> orientations()
    |> Enum.flat_map(&rotations/1)
  end
end
