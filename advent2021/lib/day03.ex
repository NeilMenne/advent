defmodule Day03 do
  @moduledoc false

  @test_input "data/day03_test.txt"

  @input "data/day03.txt"

  @zero 48
  @one 49

  def test_input, do: @test_input |> File.stream!() |> process_input()

  def input, do: @input |> File.stream!() |> process_input()

  defp process_input(stream) do
    stream
    |> Enum.map(&String.trim_trailing/1)
    |> Enum.map(&String.to_charlist/1)
  end

  @doc """
  Determine the gamma rate and epsilon rate for all values and multiply them
  together

  Each bit in the gamma rate can be determined by finding the most common bit in
  the corresponding position of all numbers in the diagnostic report.

  The epsilon rate is calculated in a similar way; rather than use the most
  common bit, the least common bit from each position is used.
  """
  def part_one([c | _] = charlists) do
    popularity_map = build_popularity_map(charlists)

    %{gamma_chars: gammas, epsilon_chars: epsilons} =
      (length(c) - 1)..0
      |> Enum.reduce(%{gamma_chars: [], epsilon_chars: []}, fn pos, acc ->
        %{@zero => zeroes, @one => ones} = Map.fetch!(popularity_map, pos)

        # NOTE: a property of the datasets exploited in part one is that there
        # are no ties
        {gamma, epsilon} =
          if zeroes > ones do
            {@zero, @one}
          else
            {@one, @zero}
          end

        acc
        |> Map.update!(:gamma_chars, &[gamma | &1])
        |> Map.update!(:epsilon_chars, &[epsilon | &1])
      end)

    gamma_rate = chars_to_int(gammas)
    epsilon_rate = chars_to_int(epsilons)

    {gamma_rate, epsilon_rate, gamma_rate * epsilon_rate}
  end

  defp build_popularity_map([c | _] = charlists) do
    base = Map.new(0..(length(c) - 1), fn pos -> {pos, %{@zero => 0, @one => 0}} end)

    charlists
    |> Enum.reduce(base, fn strs, acc ->
      strs
      |> Enum.with_index()
      |> Enum.reduce(acc, fn {char, pos}, acc ->
        update_in(acc, [pos, char], &inc/1)
      end)
    end)
  end

  defp inc(x), do: x + 1

  defp chars_to_int(chars) do
    chars
    |> to_string()
    |> String.to_integer(2)
  end

  @doc """
  Next, you should verify the life support rating, which can be determined by
  multiplying the oxygen generator rating by the CO2 scrubber rating.

  Unlike part one, we're not building up a value based on commonalities, we're
  selecting a value from a dwindling set of possible input values.
  """
  def part_two([c | _] = charlists) do
    %{oxygen: oxygen_str, co2: co2_str} =
      Enum.reduce_while(
        0..(length(c) - 1),
        %{oxygen: charlists, co2: charlists},
        &filter_for_bit(_pos = &1, _acc = &2)
      )

    o2_rating = chars_to_int(oxygen_str)
    co2_rating = chars_to_int(co2_str)

    {o2_rating, co2_rating, o2_rating * co2_rating}
  end

  # finds both ratings simultaneously, terminating whenever there's only a
  # single value for each
  defp filter_for_bit(_pos, %{oxygen: [o], co2: [c]}), do: {:halt, %{oxygen: o, co2: c}}

  defp filter_for_bit(pos, %{oxygen: os, co2: cs}) do
    # it might be wasted effort to compute the bit popularities for either if
    # there's only a single value left for the one rating
    %{@zero => o2_zeroes, @one => o2_ones} = bit_popularity(os, pos)
    %{@zero => co2_zeroes, @one => co2_ones} = bit_popularity(cs, pos)

    o2_filter = if o2_ones >= o2_zeroes, do: @one, else: @zero
    co2_filter = if co2_zeroes <= co2_ones, do: @zero, else: @one

    new_map = %{
      oxygen: filter_by_bit(os, pos, o2_filter),
      co2: filter_by_bit(cs, pos, co2_filter)
    }

    {:cont, new_map}
  end

  # unlike part one, we never need to calculate the popularities for each bit
  # simultaneously; instead, we have to be able to reconsider the most common
  # value for each bit based on an increasingly small number of remaining input
  # values
  defp bit_popularity(charlists, pos) do
    Enum.reduce(charlists, %{@zero => 0, @one => 0}, fn c, acc ->
      k = Enum.at(c, pos)

      Map.update!(acc, k, &inc/1)
    end)
  end

  # if we're done with the particular rating filter, skip
  defp filter_by_bit([x], _pos, _val), do: [x]

  defp filter_by_bit(charlists, pos, val) do
    Enum.filter(charlists, &(Enum.at(&1, pos) == val))
  end
end
