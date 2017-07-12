defmodule HelpersTest do
  use ExUnit.Case, async: true
  import RandPCG.Helpers

  test "rotate_right_32" do
    {start, _}    = "0000 0000 0000 0000 0000 0000 0010 1101"
                    |> String.replace(" ", "")
                    |> Integer.parse(2)
    {expected, _} = "1000 0000 0000 0000 0000 0000 0001 0110"
                    |> String.replace(" ", "")
                    |> Integer.parse(2)
    assert Integer.to_string(rotate_right_32(start, 1), 2) == Integer.to_string(expected, 2)
  end

end
