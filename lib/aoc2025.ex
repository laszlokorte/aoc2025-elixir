defmodule Aoc2025 do
  @moduledoc """
  Documentation for `Aoc2025`.
  """

  def day4_part1 do
    {:ok, contents} = File.read("day4.txt")

    calc(contents)
    # take only the first iteration of removing paper rolls
    |> Enum.take(1)
    |> Enum.sum()
    |> IO.puts()
  end

  def day4_part2 do
    {:ok, contents} = File.read("day4.txt")

    calc(contents)
    |> Enum.sum()
    |> IO.puts()
  end

  @neighbourhood Nx.tensor([
                   [1, 1, 1],
                   [1, 0, 1],
                   [1, 1, 1]
                 ])
                 |> Nx.new_axis(0)
                 |> Nx.new_axis(0)

  @max_neigbours 4
  @roll_char ?@

  @doc """
  Calculate how many paper rolls can be removed per iteration.
  """
  def calc(text_input_grid) do
    text_input_grid
    # Split text into grid ...
    |> String.split("\n")
    # (skip empty lines)
    |> Enum.filter(&(String.length(&1) != 0))
    # ... of chars ...
    |> Enum.map(&String.to_charlist/1)
    # ... and collect into tensor
    |> Nx.tensor()
    # ...of zeroes and ones (bool)
    |> Nx.equal(@roll_char)
    # ... turn 2d int 4d tensor because Nx.conv needs 4d
    |> Nx.new_axis(0)
    |> Nx.new_axis(0)
    # iterate until...
    |> Stream.unfold(fn remaining_rolls ->
      removable =
        remaining_rolls
        # count neighbours that are non-zero
        |> Nx.conv(@neighbourhood, padding: :same)
        # check each field for < @max_neigbours
        |> Nx.less(@max_neigbours)
        # and if the field itself is still a paper roll
        |> Nx.logical_and(remaining_rolls)

      # count how many fields are 1.0 by summing
      removable_count = removable |> Nx.sum() |> Nx.to_number()

      # of the remaining_rolls of all that can bee removed.
      rolls_left = remaining_rolls |> Nx.logical_and(Nx.logical_not(removable))

      {removable_count, rolls_left}
    end)
    # now more paper rolls can be removed
    |> Enum.take_while(&(&1 > 0))
  end
end
