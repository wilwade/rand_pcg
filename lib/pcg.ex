defmodule RandPCG.PCG do
  @moduledoc """
  Generate random numbers based on the [PCG Algorithm](http://www.pcg-random.org)
  """
  use RandPCG.Bitwise
  alias RandPCG.State

  @multiplier64 6_364_136_223_846_793_005

  @doc """
  Returns a random 32bit integer using XSH RR
  (good for 64-bit state, 32-bit output)
  """
  @spec xsh_rr(State.t) :: uint32
  def xsh_rr(%State{seed: seed}), do: xsh_rr(seed)
  @doc """
  Returns a random 32bit integer using XSH RR
  (good for 64-bit state, 32-bit output)
  """
  @spec xsh_rr(uint64) :: uint32
  def xsh_rr(seed) do
    xorshifted = (((seed >>> 18) ^^^ seed) >>> 27) &&& @mask32
    rotate = (seed >>> 59) &&& @mask64
    rotate_right_32(xorshifted, rotate)
  end

  @doc """
  Move the state forward
  """
  @spec advance(State.t) :: State.t
  def advance(%State{seed: seed, inc: inc}) do
    new_seed = (((seed * @multiplier64) &&& @mask64) + inc) &&& @mask64
    %State{seed: new_seed, inc: inc}
  end

  @doc """
  Returns random integer, x, such that, 1 <= x <= n
  """
  @spec rand_int(non_neg_integer, non_neg_integer | State.t) :: uint32
  def rand_int(n, seed) when n >= 1, do: rand_int(1, n, seed)
  @spec rand_int(non_neg_integer, non_neg_integer, any) :: uint32
  def rand_int(n, n, _seed), do: n
  @spec rand_int(non_neg_integer, non_neg_integer, uint64 | State.t) :: uint32
  def rand_int(min, max, seed) when min > max do
    rand_int(max, min, seed)
  end
  @spec rand_int(non_neg_integer, non_neg_integer, State.t) :: uint32
  def rand_int(min, max, %State{seed: seed}), do: rand_int(min, max, seed)
  @doc """
  Returns random integer, x, such that, min <= x <= max
  """
  @spec rand_int(non_neg_integer, non_neg_integer, uint64) :: uint32
  def rand_int(min, max, seed) do
    trunc(min + xsh_rr(seed) / (@mask32 / (1 + max - min)))
  end

  @doc """
  Generate a state from `:os.system_time(:micro_seconds)` and advance it once
  """
  @spec gen_state() :: State.t
  def gen_state do
    advance(State.gen_state())
  end

end
