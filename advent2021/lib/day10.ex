defmodule Day10 do
  @moduledoc false

  def process_input(filename) do
    filename
    |> File.stream!()
    |> Enum.map(fn str ->
      str
      |> String.trim_trailing()
      |> String.codepoints()
    end)
  end

  @doc """
  Identify the corrupted lines and the first mismatched closing character.
  Compute the score for each corrupted character encountered and sum the result.
  """
  def part_one(inputs) do
    inputs
    |> Enum.map(&to_stack/1)
    |> Enum.reject(fn {state, _} -> state == :incomplete end)
    |> Enum.map(fn {:corrupted, char} -> score_corrupted_char(char) end)
    |> Enum.sum()
  end

  @doc """
  Turn the input line into a stack of remaining characters

  Processes the input characters by pushing opening characters onto the stack
  and popping them iff the correct closing char is present.

  For corrupted lines, we halt immediately on the invalid closing char and
  return it.
  """
  def to_stack(line) do
    stack_or_char =
      Enum.reduce_while(line, [], fn char, stack ->
        cond do
          open?(char) ->
            {:cont, [char | stack]}

          valid_close?(char, stack) ->
            [_ | stack] = stack
            {:cont, stack}

          true ->
            {:halt, char}
        end
      end)

    if is_binary(stack_or_char) do
      {:corrupted, stack_or_char}
    else
      {:incomplete, stack_or_char}
    end
  end

  defp open?(char), do: char in ["(", "[", "{", "<"]

  defp valid_close?(")", ["(" | _rest]), do: true
  defp valid_close?("]", ["[" | _rest]), do: true
  defp valid_close?("}", ["{" | _rest]), do: true
  defp valid_close?(">", ["<" | _rest]), do: true
  defp valid_close?(_, _), do: false

  defp score_corrupted_char(")"), do: 3
  defp score_corrupted_char("]"), do: 57
  defp score_corrupted_char("}"), do: 1197
  defp score_corrupted_char(">"), do: 25137

  @doc """
  Removing the corrupted lines, determine the missing closing characters and
  score the lines according to the specified scoring algorithm.

  There should be an odd number of incomplete lines such that you can take the
  precise midpoint of the scores after sorting.
  """
  def part_two(inputs) do
    scores =
      inputs
      |> Enum.map(&to_stack/1)
      |> Enum.reject(fn {state, _} -> state == :corrupted end)
      |> Enum.map(&score_incomplete_chars/1)

    mid = div(length(scores), 2)

    scores
    |> Enum.sort()
    |> Enum.at(mid)
  end

  @doc """
  Score the remaining opening characters

  Since we used a list as a stack, the state of the stack can be scored against
  the opening characters in the current order rather than needing to actually
  enumerate the closing characters for each opener and scoring that.
  """
  def score_incomplete_chars({:incomplete, chars}) do
    Enum.reduce(chars, 0, fn char, acc ->
      acc * 5 + score_incomplete_char(char)
    end)
  end

  defp score_incomplete_char("("), do: 1
  defp score_incomplete_char("["), do: 2
  defp score_incomplete_char("{"), do: 3
  defp score_incomplete_char("<"), do: 4
end
