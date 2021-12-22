defmodule Day21 do
  @test_input %{
    p1: %{score: 0, position: 4},
    p2: %{score: 0, position: 8},
    current: :p1
  }

  @input %{
    p1: %{score: 0, position: 2},
    p2: %{score: 0, position: 5},
    current: :p1
  }

  def test_input, do: @test_input
  def input, do: @input

  def part_one(input) do
    %{p1: %{score: s1}, p2: %{score: s2}, rolls: r} = play_p1_game(input)

    if s1 > s2, do: s2 * r, else: s1 * r
  end

  def play_p1_game(state) do
    state =
      state
      |> Map.put(:rolls, 0)

    Stream.cycle(1..100)
    |> Stream.chunk_every(3)
    |> Stream.transform(state, fn rolls, state ->
      next_state =
        move_player(state, Enum.sum(rolls))
        |> Map.update!(:rolls, &(&1 + 3))

      {[next_state], next_state}
    end)
    |> Enum.find(fn %{p1: p1, p2: p2} -> p1.score >= 1000 or p2.score >= 1000 end)
  end

  defp move_player(%{current: :p1, p1: %{position: p}} = state, offset) do
    new_position = rem(p + offset - 1, 10) + 1

    state
    |> put_in([:p1, :position], new_position)
    |> update_in([:p1, :score], &(&1 + new_position))
    |> flip_player()
  end

  defp move_player(%{current: :p2, p2: %{position: p}} = state, offset) do
    new_position = rem(p + offset - 1, 10) + 1

    state
    |> put_in([:p2, :position], new_position)
    |> update_in([:p2, :score], &(&1 + new_position))
    |> flip_player()
  end

  defp flip_player(%{current: :p1} = s), do: %{s | current: :p2}
  defp flip_player(%{current: :p2} = s), do: %{s | current: :p1}

  @roll_freqs Enum.frequencies(for i <- 1..3, j <- 1..3, k <- 1..3, do: i + j + k)

  def part_two(input) do
    {p1, p2} =
      Stream.iterate({%{input => 1}, {0, 0}}, fn {states, wins} ->
        for {state, count} <- states, {roll, freq} <- @roll_freqs, reduce: {%{}, wins} do
          {next_states, {p1, p2}} ->
            s = move_player(state, roll)

            # if either player wins, they won `count * freq` games; otherwise,
            # add that game state to the next set of states to try or update the
            # count for that particular state
            val = count * freq

            cond do
              s.p1.score >= 21 -> {next_states, {p1 + val, p2}}
              s.p2.score >= 21 -> {next_states, {p1, p2 + val}}
              true -> {Map.update(next_states, s, val, &(&1 + val)), {p1, p2}}
            end
        end
      end)
      |> Enum.find(fn {states, _} -> map_size(states) == 0 end)
      |> elem(1)

    max(p1, p2)
  end
end
