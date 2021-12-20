defmodule Day20 do
  @moduledoc false

  def process_input(filename) do
    [enhance_str, img_str] =
      filename
      |> File.read!()
      |> String.split("\n\n", trim: true)

    enhance =
      enhance_str
      |> String.replace("\n", "")
      |> String.codepoints()
      |> Enum.with_index()
      |> Map.new(fn {v, idx} ->
        v = if v == "#", do: 1, else: 0
        {idx, v}
      end)

    img_str
    |> to_img_struct()
    |> Map.put(:enhance, enhance)
  end

  defp to_img_struct(img_str) do
    [first | _] =
      pixels =
      img_str
      |> String.split("\n", trim: true)
      |> Enum.map(&String.codepoints/1)

    grid =
      for h <- 0..(length(pixels) - 1),
          w <- 0..(length(first) - 1) do
        v = if get_in(pixels, [Access.at(h), Access.at(w)]) == "#", do: 1, else: 0

        {{h, w}, v}
      end
      |> Map.new()

    %{grid: grid, min: 0, max: length(pixels) + 1}
  end

  @doc """
  Visualize the state of the image
  """
  def draw_img(%{grid: grid, min: min, max: max}) do
    Enum.map(min..max, fn h ->
      str =
        for w <- min..max do
          if Map.get(grid, {h, w}) == 1, do: "#", else: "."
        end
        |> Enum.join()

      str <> "\n"
    end)
    |> IO.puts()
  end

  def part_one(img) do
    enhance(img, 2)
    |> Map.fetch!(:grid)
    |> Enum.filter(fn {_, val} -> val == 1 end)
    |> length()
  end

  def part_two(img) do
    enhance(img, 50)
    |> Map.fetch!(:grid)
    |> Enum.filter(fn {_, val} -> val == 1 end)
    |> length()
  end

  def enhance(img, steps), do: enhance_recur(img, 0, steps)

  defp enhance_recur(img, _parity?, 0), do: img

  defp enhance_recur(%{min: min, max: max, enhance: emap} = img, parity?, steps) do
    new_min = min - 1
    new_max = max + 1
    range = new_min..new_max

    new_grid =
      for h <- range, w <- range do
        addr = to_addr({h, w}, parity?, img.grid)

        val = emap[addr]

        {{h, w}, val}
      end
      |> Map.new()

    # why is this required? b/c while it is the case that every iteration will
    # have an infinite space of _initially_ dark spots, those positions do
    # flicker. to verify, look at emap[0] and emap[511].
    parity? = if parity? == 0, do: emap[0], else: emap[511]

    enhance_recur(%{img | grid: new_grid, min: new_min, max: new_max}, parity?, steps - 1)
  end

  defp to_addr({h0, w0}, parity, grid) do
    for h <- (h0 - 1)..(h0 + 1), w <- (w0 - 1)..(w0 + 1) do
      {h, w}
    end
    |> Enum.reduce(0, fn curr, addr ->
      curr_bit = grid[curr] || parity

      2 * addr + curr_bit
    end)
  end
end
