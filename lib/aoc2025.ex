defmodule Aoc2025 do
  @moduledoc """
  Documentation for `Aoc2025`.
  """

  def day4_part1 do
    {:ok, contents} = File.read("day4.txt")

    calc(contents)
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

  def calc(contents) do
    rows = contents |> String.split("\n") |> Enum.filter(&(String.length(&1) != 0))
    cols = rows |> Enum.map(&String.to_charlist/1)
    tensor = Nx.tensor(cols)
    {h, w} = Nx.shape(tensor)

    rolls = Nx.equal(tensor, 64) |> Nx.broadcast({1, 1, h, w})
    box_filter = Nx.broadcast(1.0, {1, 1, 3, 3})

    Stream.unfold(rolls, fn remaining_rolls ->
      neighbour_sum = Nx.conv(remaining_rolls, box_filter, padding: :same)
      reachable = Nx.less(neighbour_sum, 5)
      removable = Nx.logical_and(remaining_rolls, reachable)
      removable_count = Nx.sum(removable) |> Nx.to_number()
      {removable_count, Nx.logical_and(remaining_rolls, Nx.logical_not(removable))}
    end)
    |> Enum.take_while(&(&1 > 0))
  end
end
