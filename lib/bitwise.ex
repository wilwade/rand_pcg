defmodule RandPCG.Bitwise do
  @moduledoc """
  Bitwise helpers

  `use RandPCG.Bitwise` pulls in:
  - `use Bitwise, only_operators: true`
  - `@mask64 0xFFFFFFFFFFFFFFFF`
  - `@mask32 0xFFFFFFFF`
  - Types `uint32` and `uint64` which are shorthand for `non_neg_integer`
  """
  use Bitwise, only_operators: true

  defmacro __using__(_) do
    quote do
      use Bitwise, only_operators: true
      import RandPCG.Bitwise
      @mask64 0xFFFFFFFFFFFFFFFF
      @mask32 0xFFFFFFFF

      @typedoc """
      32 bit unsigned integer
      Elixir has arbitrary precision, but the random numbers are limited
      """
      @type uint32 :: non_neg_integer
      @typedoc """
      64 bit unsigned integer
      Elixir has arbitrary precision, but the random numbers are limited
      """
      @type uint64 :: non_neg_integer
    end
  end

  @mask32 0xFFFFFFFF

  @doc """
  Performs a 32 bit right bit rotation of v for n places
  """
  @spec rotate_right_32(RandPCG.uint64, RandPCG.uint64) :: RandPCG.uint32
  def rotate_right_32(v, n) do
    n = n &&& 31
    ((v >>> n) ||| (v <<< (-n &&& 31))) &&& @mask32
  end
end
