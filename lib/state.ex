defmodule RandPCG.State do
  @moduledoc """
  Struct to hold the seed and incrimenter
  """
  use RandPCG.Bitwise

  defstruct seed: nil, inc: 1

  @typedoc """
  Struct to hold the seed and incrimenter
  """
  @type t :: %RandPCG.State{seed: uint64, inc: non_neg_integer}

  @doc """
  Generates a new seed based on `:os.system_time(:micro_seconds)`
  """
  @spec gen_seed() :: uint64
  def gen_seed, do: :os.system_time(:micro_seconds) &&& @mask64

  @doc """
  Generates a new state with seed based on `:os.system_time(:micro_seconds)`
  """
  @spec gen_state() :: RandPCG.State.t
  def gen_state, do: %RandPCG.State{seed: gen_seed(), inc: 1}
end
