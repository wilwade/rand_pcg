defmodule RandPCGTest do
  use ExUnit.Case, async: true
  import RandPCG

  setup do
    start_link()
    :ok
  end

  test "returns a random number 0 - 1" do
    r = random(:float)
    assert r >= 0
    assert r <= 1
  end

  test "returns an array of n random numbers" do
    r = random(20)
    assert Enum.count(r) == 20
  end

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

  test "random enum" do
    state = %RandPCG.State{seed: 0x0ddc0ffeebadf00d, inc: 0xcafebabf}
    state(state)
    list = [:a, :b, :c, :d]
    assert :d == RandPCG.random(list)
  end
end
