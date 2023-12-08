defmodule Advent2023.Day07 do
  def process_input(file_loc) do
    file_loc
    |> File.stream!()
    |> Enum.map(&String.trim_trailing/1)
    |> Enum.map(&parse_line/1)
  end

  defp parse_line(str) do
    [card_str, bid_str] = String.split(str)

    vs =
      card_str
      |> String.codepoints()
      |> Enum.map(&to_val/1)

    pow = determine_hand_type(vs)

    bid = String.to_integer(bid_str)

    %{bid: bid, pow: pow, vals: vs}
  end

  defp to_val("A"), do: 14
  defp to_val("K"), do: 13
  defp to_val("Q"), do: 12
  defp to_val("J"), do: 11
  defp to_val("T"), do: 10
  defp to_val(i), do: String.to_integer(i)

  def determine_hand_type(cards) do
    freqs =
      cards
      |> Enum.frequencies()
      |> Map.values()
      |> Enum.sort(:desc)

    freq_to_pow(freqs)
  end

  # POW(7) - Five of a kind, where all five cards have the same label: AAAAA
  # POW(6) - Four of a kind, where four cards have the same label and one card
  #          has a different label: AA8AA
  # POW(5) - Full house, where three cards have the same label, and the
  #          remaining two cards share a different label: 23332
  # POW(4) - Three of a kind, where three cards have the same label, and the
  #          remaining two cards are each different from any other card in the
  #          hand: TTT98
  # POW(3) - Two pair, where two cards share one label, two other cards share a
  #          second label, and the remaining card has a third label: 23432
  # POW(2) - One pair, where two cards share one label, and the other three
  #          cards have a different label from the pair and each other: A23A4
  # POW(1) - High card, where all cards' labels are distinct: 23456
  defp freq_to_pow(freqs) do
    case freqs do
      [5] -> 7
      [4 | _] -> 6
      [3, 2] -> 5
      [3 | _] -> 4
      [2, 2 | _] -> 3
      [2 | _] -> 2
      _ -> 1
    end
  end

  @doc """
  Find the rank of every hand in your set. What are the total winnings?
  """
  def part1(hands) do
    hands
    |> Enum.sort_by(& &1, &hand_ordering/2)
    |> Enum.with_index(1)
    |> Enum.map(fn {%{bid: b}, r} -> b * r end)
    |> Enum.sum()
  end

  # If two hands have the same type, a second ordering rule takes effect. Start by
  # comparing the first card in each hand. If these cards are different, the hand
  # with the stronger first card is considered stronger. If the first card in each
  # hand have the same label, however, then move on to considering the second card
  # in each hand. If they differ, the hand with the higher second card wins;
  # otherwise, continue with the third card in each hand, then the fourth, then
  # the fifth.
  defp hand_ordering(%{pow: p} = l, %{pow: p} = r), do: by_vals(l.vals, r.vals)
  defp hand_ordering(%{pow: p0}, %{pow: p1}), do: p0 < p1

  defp by_vals([h | r0], [h | r1]), do: by_vals(r0, r1)
  defp by_vals([h0 | _r0], [h1 | _r1]), do: h0 < h1

  @doc """
  Using the new joker rule, find the rank of every hand in your set. What are
  the new total winnings?

  J cards can pretend to be whatever card is best for the purpose of determining
  hand type; for example, QJJQ2 is now considered four of a kind. However, for the
  purpose of breaking ties between two hands of the same type, J is always treated
  as J, not the card it's pretending to be: JKKK2 is weaker than QQQQ2 because J
  is weaker than Q.

  To balance this, J cards are now the weakest individual cards, weaker even
  than 2.
  """
  def part2(hands) do
    hands
    |> Enum.map(&remap_jokers/1)
    |> Enum.sort_by(& &1, &hand_ordering/2)
    |> Enum.with_index(1)
    |> Enum.map(fn {%{bid: b}, r} -> b * r end)
    |> Enum.sum()
  end

  defp remap_jokers(hand) do
    freq_map = Enum.frequencies(hand.vals)

    cond do
      Map.has_key?(freq_map, 11) and map_size(freq_map) > 1 ->
        hand
        |> update_vals()
        |> update_hand_type(freq_map)

      Map.has_key?(freq_map, 11) ->
        update_vals(hand)

      true ->
        hand
    end
  end

  defp update_vals(%{vals: vs} = h) do
    vs = Enum.map(vs, fn v -> if v == 11, do: 1, else: v end)

    %{h | vals: vs}
  end

  defp update_hand_type(hand, freq_map) do
    {j, m} = Map.pop(freq_map, 11)

    [v | rest] = m |> Map.values() |> Enum.sort(:desc)

    freqs = [v + j | rest]

    Map.put(hand, :pow, freq_to_pow(freqs))
  end
end
