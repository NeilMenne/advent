defmodule Advent2023.Day05 do
  @doc """
  Unlike previous days where a line-by-line approach is sufficient, we have to
  treat sections of the file as related
  """
  def process_input(file_loc) do
    text = File.read!(file_loc) |> String.trim_trailing()

    [seed_str | maps_strs] = String.split(text, "\n\n")

    seeds =
      seed_str
      |> String.replace("seeds: ", "")
      |> String.split()
      |> Enum.map(&String.to_integer/1)

    almanac = Map.new(maps_strs, &parse_map/1)

    {seeds, almanac}
  end

  def parse_map(str) do
    [name_line | mapping_lines] = String.split(str, "\n")

    [source, dest] =
      name_line
      |> String.replace(" map:", "")
      |> String.split("-to-")
      |> Enum.map(&String.to_atom/1)

    mappings =
      mapping_lines
      |> Enum.map(&String.split/1)
      |> Enum.map(fn nums ->
        [dest_min, src_min, len] = Enum.map(nums, &String.to_integer/1)

        %{src: src_min..(src_min + len - 1), delta: dest_min - src_min}
      end)

    {source, %{dest: dest, mappings: mappings}}
  end

  @doc """
  What is the lowest location number that corresponds to any of the initial seed
  numbers?
  """
  def part1({seeds, almanac}) do
    seeds
    |> Enum.map(&perform_mapping(&1, almanac))
    |> Enum.min()
  end

  defp perform_mapping(seed, almanac), do: perform_mapping(:seed, seed, almanac)

  defp perform_mapping(:location, dom, _almanac), do: dom

  defp perform_mapping(src, dom, almanac) do
    %{dest: dest, mappings: ms} = Map.fetch!(almanac, src)

    m = Enum.find(ms, %{delta: 0}, &matching_range?(&1, dom))

    cod = dom + m.delta

    perform_mapping(dest, cod, almanac)
  end

  defp matching_range?(m, dom), do: dom in m.src

  @doc """
  What is the lowest location number that corresponds to any of the initial seed
  numbers?

  The values on the initial seeds: line come in pairs. Within each pair, the
  first value is the start of the range and the second value is the length of
  the range.
  """
  def part2({seeds, almanac}) do
    seed_ranges =
      seeds
      |> Enum.chunk_every(2)
      |> Enum.map(fn [s, l] -> s..(s + l - 1) end)

    seed_ranges
    |> propagate_ranges(almanac)
    |> Enum.map(& &1.first)
    |> Enum.min()
  end

  defp propagate_ranges(seed_rngs, almanac), do: propagate_ranges(:seed, seed_rngs, almanac)

  defp propagate_ranges(:location, dom_rngs, _), do: dom_rngs

  defp propagate_ranges(src, doms, almanac) do
    %{mappings: ms, dest: dest} = Map.fetch!(almanac, src)

    {pass, cod_rngs} =
      Enum.reduce(ms, {doms, []}, fn m, {doms, cods} ->
        {n_doms, n_cods} = split_domain(doms, m)

        {n_doms, n_cods ++ cods}
      end)

    # `pass` is the set of ranges that couldn't be mapped via any functions;
    # they are passed through as if they belong to the codomain
    propagate_ranges(dest, pass ++ cod_rngs, almanac)
  end

  defp split_domain(doms, rng) do
    {n_doms, n_cods} =
      doms
      |> Enum.map(&split_range(&1, rng))
      |> Enum.unzip()

    {List.flatten(n_doms), List.flatten(n_cods)}
  end

  @doc """
  Given an input range in `dom` and a mapping function %{src: Range.t(),
  delta: number()}, create subranges in the domain and the codomain (where
  applicable)
  """
  def split_range(dom, %{src: src, delta: delta}) do
    cond do
      # subrange is disjoint from the particular mapping
      Range.disjoint?(dom, src) ->
        {[dom], []}

      # subrange is a subset of the particular mapping
      dom.first >= src.first and dom.last <= src.last ->
        {[], [(dom.first + delta)..(dom.last + delta)]}

      # subrange covers the particular mapping
      dom.first < src.first and dom.last > src.last ->
        prior = dom.first..(src.first - 1)
        covered = (src.first + delta)..(src.last + delta)
        post = (src.last + 1)..dom.last

        {[prior, post], [covered]}

      # subrange is prior and overlapping
      dom.first < src.first ->
        prior = dom.first..(src.first - 1)
        covered = (src.first + delta)..(dom.last + delta)

        {[prior], [covered]}

      # subrange starts w/in the particular mapping and extends beyond
      true ->
        covered = (dom.first + delta)..(src.last + delta)
        post = (src.last + 1)..dom.last

        {[post], [covered]}
    end
  end
end
