defmodule RandPCG.Worker do
  @moduledoc """
  GenServer for generating random numbers based on the
  [PCG Algorithm](http://www.pcg-random.org)
  """
  use GenServer
  use RandPCG.Bitwise
  alias RandPCG.State
  import RandPCG.PCG

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, opts)
  end

  def init(opts) do
    seed = Keyword.get(opts, :seed, State.gen_seed())
    inc = Keyword.get(opts, :inc, System.unique_integer([:positive]))
    {:ok, advance(%State{seed: seed, inc: inc})}
  end

  def handle_call(:random_32_int, _from, state) do
    r = xsh_rr(state)
    {:reply, r, advance(state)}
  end

  def handle_call({:random_32_int, count}, _from, state) do
    {result, state} = Enum.reduce(1..count, {[], state},
      fn(_nth, {list, state}) ->
        r = xsh_rr(state)
        {[r | list], advance(state)}
      end)
    {:reply, result, state}
  end

  def handle_call({:random_32_int, min, max}, _from, state) do
    r = rand_int(min, max, state.seed)
    {:reply, r, advance(state)}
  end

  def handle_call({:random_32_int, min, max, count}, _from, state) do
    {result, state} = Enum.reduce(1..count, {[], state},
      fn(_nth, {list, state}) ->
        r = rand_int(min, max, state.seed)
        {[r | list], advance(state)}
      end)
    {:reply, result, state}
  end

  def handle_call(:random_32_float, _from, state) do
    r = xsh_rr(state) / @mask32
    {:reply, r, advance(state)}
  end

  def handle_call({:random_32_float, count}, _from, state) do
    {result, state} = Enum.reduce(1..count, {[], state},
      fn(_nth, {list, state}) ->
        r = xsh_rr(state) / @mask32
        {[r | list], advance(state)}
      end)
    {:reply, result, state}
  end

  def handle_call({:random_enum, enum}, _from, %State{seed: seed} = state) do
    case Enum.count(enum) do
      0 ->
        raise Enum.EmptyError
      count ->
        {:reply, Enum.at(enum, rand_int(0, count - 1, seed)), advance(state)}
    end
  end

  def handle_call(:seed, _from, state) do
    {:reply, state, state}
  end
  def handle_call({:seed, seed}, _from, %State{inc: inc}) do
    {:reply, seed, %State{seed: seed, inc: inc}}
  end

  def handle_call(:inc, _from, state) do
    {:reply, state, state}
  end
  def handle_call({:inc, inc}, _from, %State{seed: seed}) do
    {:reply, inc, %State{seed: seed, inc: inc}}
  end

  def handle_call(:state, _from, state) do
    {:reply, state, state}
  end
  def handle_call({:state, state}, _from, _state) do
    {:reply, state, state}
  end

end
