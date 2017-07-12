defmodule PCGTest do
  use ExUnit.Case, async: true
  import RandPCG.PCG

  test "advance" do
    state = %RandPCG.State{seed: 998690804919562253, inc: 3405691583}
            |> advance()
    assert state.seed == 4283394408209539080
  end

  test "xsh_rr" do
    state = %RandPCG.State{seed: 0x0ddc0ffeebadf00d, inc: 0xcafebabf}

    "test/numbers.txt"
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.reduce(state, fn (expect, state) ->
      {expected, _} = Integer.parse(expect)
      assert expected == xsh_rr(state)
      advance(state)
    end)

  end

  test "rand_int" do
    state = %RandPCG.State{seed: 0x0ddc0ffeebadf00d, inc: 0xcafebabf}
    assert 5 == rand_int(5, state)
    state = advance(state)
    assert 2 == rand_int(5, state)
    state = advance(state)
    assert 7 == rand_int(5, 10, state)
  end
end
