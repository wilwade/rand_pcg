defmodule RandPCG.Helpers do
  @moduledoc """
  Bitwise helpers
  """
  use Bitwise, only_operators: true

  @mask32 0xFFFFFFFF

  @spec rotate_right_32(RandPCG.uint64, RandPCG.uint64) :: RandPCG.uint32
  def rotate_right_32(v, rotate) do
    rotate = rotate &&& 31
    ((v >>> rotate) ||| (v <<< (-rotate &&& 31))) &&& @mask32
  end
end
