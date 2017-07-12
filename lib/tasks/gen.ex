defmodule Mix.Tasks.Gen do
  @moduledoc """
  Generates random numbers at the command line.

  ## Example: Using the NIST Statistical Test Suite
  1. Download & install the suite:
  http://csrc.nist.gov/groups/ST/toolkit/rng/documentation_software.html
  2. `mix gen :nist 100000 > random.txt`
  3. Run the suite using `random.txt`
  """
  use Mix.Task

  def run([]), do: IO.puts(docs())
  def run(["nist", count]) do
    {count, _} = Integer.parse(count)
    RandPCG.start

    count
    |> generate_random_32()
    |> Enum.each(&output_binary(&1))
  end
  def run([count]) do
    {count, _} = Integer.parse(count)
    RandPCG.start

    count
    |> generate_random_32()
    |> Enum.each(&IO.puts(&1))
  end

  def docs do
    """
      Generates a count of random 32 bit integers
      $ mix gen [count]

      Optional generate random 32 bit integers as binary strings:
      $ mix gen nist [count]
      (Used for the nist statistical test)
    """
  end

  def generate_random_32(count) do
    RandPCG.random(count)
  end

  def output_binary(x) do
    x
    |> Integer.to_string(2)
    |> String.pad_leading(32, "0")
    |> IO.puts()
  end

end
