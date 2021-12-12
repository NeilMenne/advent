defmodule Day12 do
  @moduledoc false

  def process_input(filename) do
    File.stream!(filename)
    |> Enum.map(fn str ->
      str
      |> String.trim_trailing()
      |> String.split("-")
    end)
    |> to_graph()
  end

  defp to_graph(edges) do
    Enum.reduce(edges, %{}, fn [left, right], acc ->
      {left_name, left_type} = identify(left)
      {right_name, right_type} = identify(right)

      left_default = %{type: left_type, edges: [right_name]}
      right_default = %{type: right_type, edges: [left_name]}

      acc
      |> Map.update(left_name, left_default, &%{&1 | edges: [right_name | &1.edges]})
      |> Map.update(right_name, right_default, &%{&1 | edges: [left_name | &1.edges]})
    end)
  end

  defp identify("start"), do: {:source, :small}
  defp identify("end"), do: {:sink, :small}

  defp identify(str) do
    if String.upcase(str) == str do
      {str, :big}
    else
      {str, :small}
    end
  end

  @doc """
  Count the number of distinct paths in the graph from :source to :sink

  * Paths are allowed to revisit a :big node as many times as necessary
  * Paths are allowed to visit a :small node _at most once_
  * Taken together, this means that some nodes may never be visited
  """
  def part_one(graph), do: collect_paths(graph, &revisit_any_small?/2)

  defp revisit_any_small?(path, graph) do
    path
    |> Enum.frequencies()
    |> Enum.any?(fn {k, visits} ->
      get_in(graph, [k, :type]) == :small and visits > 1
    end)
  end

  @doc """
  Part Two: allow a _single_ small cave to be revisited twice; the small cave
  cannot be :source or :sink. The latter requirement is covered by the first
  `Enum.reject/2` in `collect_paths_recur/4`.

  This means we effectively have 3 things to watch out for when doing the
  traversal.

  1. Source should never be revisited
  2. At most one small node should be revisited once
  3. No small node should be revisited more than once
  """
  def part_two(graph), do: collect_paths(graph, &revisit_at_most_one_small?/2)

  defp revisit_at_most_one_small?(path, graph) do
    small_freqs =
      path
      |> Enum.frequencies()
      |> Map.drop(big_nodes(graph))

    visited_twice? =
      small_freqs
      |> Enum.filter(fn {_k, visits} -> visits == 2 end)
      |> length()
      |> Kernel.>(1)

    visited_too_many_times? = Enum.any?(small_freqs, fn {_k, visits} -> visits > 2 end)

    small_freqs[:source] == 2 or visited_twice? or visited_too_many_times?
  end

  defp big_nodes(graph) do
    graph
    |> Map.keys()
    |> Enum.filter(&(get_in(graph, [&1, :type]) == :big))
  end

  @doc """

  Pseudo-breadth-first traversal that starts at `:source` and enumerates all
  paths given some criteria for valid paths through the graph. To make the
  process more memory efficient, paths are counted rather than returned once
  completed.

  `graph` is expected to have an pruning function under the key `:prune_fn` that
  is used to eliminate invalid paths from further consideration.
  """
  def collect_paths(graph, prune_fn) do
    paths = Enum.map(graph.source.edges, &[:source, &1])

    collect_paths_recur(graph, prune_fn, paths, 0)
  end

  defp collect_paths_recur(_graph, _prune_fn, [], completed), do: completed

  defp collect_paths_recur(graph, prune_fn, [nxt | rest], completed) do
    node =
      nxt
      |> List.last()
      |> then(&Map.fetch!(graph, &1))

    extended =
      node.edges
      |> Enum.map(&(nxt ++ [&1]))

    completed =
      extended
      |> Enum.filter(&(List.last(&1) == :sink))
      |> length()
      |> Kernel.+(completed)

    pruned =
      extended
      |> Enum.reject(&(List.last(&1) == :sink))
      |> Enum.reject(fn path -> prune_fn.(path, graph) end)

    collect_paths_recur(graph, prune_fn, pruned ++ rest, completed)
  end
end
