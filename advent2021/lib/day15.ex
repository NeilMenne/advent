defmodule Day15 do
  @moduledoc false

  def process_input(filename) do
    points =
      filename
      |> File.stream!()
      |> Enum.map(fn str ->
        str
        |> String.trim_trailing()
        |> String.graphemes()
        |> Enum.map(&String.to_integer/1)
      end)

    to_grid(points)
  end

  defp to_grid([r | _] = rows) do
    width = length(r)
    height = length(rows)

    for h <- 0..(height - 1), w <- 0..(width - 1), into: %{} do
      risk = get_in(rows, [Access.at(h), Access.at(w)])

      {{h, w}, risk}
    end
  end

  def part_one(grid), do: solve(grid, 1)

  def part_two(grid), do: solve(grid, 5)

  @doc """
  Applies the scaling factor as a value to track rather than scaling the entire
  grid as specified in the input

  Modified Dijkstra's Algorithm was required for Part Two.
  """
  def solve(grid, scaling_factor) when scaling_factor in [1, 5] do
    {dest_h, dest_w} = destination(grid)

    {dh, dw} = size = {dest_h + 1, dest_w + 1}

    grid = Map.put(grid, :size, size)

    dest = {dh * scaling_factor - 1, dw * scaling_factor - 1}

    start = {0, {0, 0}}

    queue =
      PriorityQueue.new()
      |> PriorityQueue.put(start)

    dijkstras_alg_recur(start, grid, %{}, queue, dest)
  end

  defp destination(grid) do
    grid
    |> Map.keys()
    |> Enum.max_by(fn {h, w} -> h + w end)
  end

  @infinity 999_999

  defp dijkstras_alg_recur({risk, {d_y, d_x}}, _g, _c, _q, {d_y, d_x}), do: risk

  defp dijkstras_alg_recur({risk, curr}, grid, cost, queue, dest) do
    queue = PriorityQueue.delete_min!(queue)

    if Map.get(cost, curr, @infinity) > risk do
      cost = Map.put(cost, curr, risk)

      queue =
        curr
        |> neighbors(dest)
        |> update_queue(risk, grid, cost, queue)

      next = PriorityQueue.min!(queue)
      dijkstras_alg_recur(next, grid, cost, queue, dest)
    else
      dijkstras_alg_recur(PriorityQueue.min!(queue), grid, cost, queue, dest)
    end
  end

  defp neighbors({h0, w0}, {h_max, w_max}) do
    [{h0 - 1, w0}, {h0 + 1, w0}, {h0, w0 - 1}, {h0, w0 + 1}]
    |> Enum.filter(fn {h1, w1} ->
      between(h1, 0, h_max) and between(w1, 0, w_max)
    end)
  end

  defp between(x, bot, top), do: x >= bot and x <= top

  # curr_risk is the risk of the current node in the graph such that the normal
  # Dijkstra algorithm rules apply; instead of updating the cost in the map, we
  # choose to add any improvement to the queue
  defp update_queue(ns, curr_risk, grid, cost, queue) do
    Enum.reduce(ns, queue, fn {h, w} = n, queue ->
      prev_risk = Map.get(cost, n, @infinity)

      # base grid size
      {h_max, w_max} = grid[:size]

      # location of the base risk
      h_orig = rem(h, h_max)
      w_orig = rem(w, w_max)

      # offsets are applied to the risk of the base
      h_off = div(h, h_max)
      w_off = div(w, w_max)

      offset = grid[{h_orig, w_orig}] + h_off + w_off
      scaled = if offset > 9, do: offset - 9, else: offset

      new_risk = curr_risk + scaled

      if new_risk < prev_risk do
        PriorityQueue.put(queue, {new_risk, n})
      else
        queue
      end
    end)
  end
end
