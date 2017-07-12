defmodule RandPCGTest do
  use ExUnit.Case, async: true
  import RandPCG

  setup do
    start(nil, nil)
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

  test "random enum" do
    state = %RandPCG.State{seed: 0x0ddc0ffeebadf00d, inc: 0xcafebabf}
    state(state)
    list = [:a, :b, :c, :d]
    assert :d == RandPCG.random(list)
  end
end
