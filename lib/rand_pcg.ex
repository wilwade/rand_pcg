defmodule RandPCG do
  @moduledoc """
  Generate random numbers based on the [PCG Algorithm](http://www.pcg-random.org)
  """
  use GenServer
  use Bitwise, only_operators: true
  import RandPCG.Helpers

  @name RandPCG

  @multiplier64 6_364_136_223_846_793_005
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

  defmodule State do
    @moduledoc """
    Struct to hold the seed and incrimenter
    """
    @mask64 0xFFFFFFFFFFFFFFFF
    defstruct seed: nil, inc: 1

    @typedoc """
    Struct to hold the seed and incrimenter
    """
    @type t :: %State{seed: RandPCG.uint64, inc: non_neg_integer}

    @doc """
    Generates a new seed based on `:os.system_time(:micro_seconds)`
    """
    @spec gen_seed() :: RandPCG.uint64
    def gen_seed, do: :os.system_time(:micro_seconds) &&& @mask64

    @doc """
    Generates a new state with seed based on `:os.system_time(:micro_seconds)`
    """
    @spec gen_state() :: State.t
    def gen_state, do: %State{seed: gen_seed(), inc: 1}
  end

  def start_link(opts \\ []) do
    opts = Keyword.put_new(opts, :name, @name)
    GenServer.start_link(__MODULE__, opts, opts)
  end

  def init(opts) do
    seed = Keyword.get(opts, :seed, State.gen_seed())
    inc = Keyword.get(opts, :inc, 1)
    {:ok, advance(%State{seed: seed, inc: inc})}
  end

  @doc """
  Returns a random 32bit integer
  ## Examples
      iex> RandPCG.start_link
      iex> RandPCG.random
      3242229798

  """
  @spec random() :: uint32
  def random do
    GenServer.call(@name, :random_32_int)
  end
  @doc """
  Returns a random 32bit based float
  """
  @spec random(:float) :: float
  def random(:float) do
    GenServer.call(@name, :random_32_float)
  end
  @doc """
  Returns an array of random 32bit integers of length count
  """
  @spec random(non_neg_integer) :: [uint32]
  def random(count) when is_integer(count) do
    GenServer.call(@name, {:random_32_int, count}, timeout(count))
  end
  @doc """
  Returns a random entry from the enum max 32bit length
  """
  @spec random([term]) :: term
  def random(enum) when is_list(enum) do
    GenServer.call(@name, {:random_enum, enum})
  end
  @doc """
  Returns an array of random 32bit based floats of length count
  """
  @spec random(:float, non_neg_integer) :: [float]
  def random(:float, count) when is_integer(count) do
    GenServer.call(@name, {:random_32_float, count}, timeout(count))
  end
  @doc """
  Returns a random integer x, min <= x <= max 32bit based
  """
  @spec random(non_neg_integer, non_neg_integer) :: uint32
  def random(min, max) when is_integer(min) and is_integer(max) do
    GenServer.call(@name, {:random_32_int, min, max})
  end
  @doc """
  Returns a random integer x, min <= x <= max 32bit based
  """
  @spec random(non_neg_integer, non_neg_integer, non_neg_integer) :: [uint32]
  def random(min, max, count)
  when is_integer(min) and is_integer(max) and is_integer(count) do
    GenServer.call(@name, {:random_32_int, min, max, count}, timeout(count))
  end

  @doc """
  Sets the process seed
  """
  @spec seed(non_neg_integer) :: uint64
  def seed(seed) do
    GenServer.call(@name, {:seed, seed})
  end

  @doc """
  Sets the process incrimenter
  """
  @spec inc(non_neg_integer) :: non_neg_integer
  def inc(inc) do
    GenServer.call(@name, {:inc, inc})
  end

  @doc """
  Returns the current state of the process
  """
  @spec state() :: State.t
  def state do
    GenServer.call(@name, :state)
  end
  @doc """
  Sets the current state of the process
  """
  @spec state(State.t) :: State.t
  def state(state) do
    GenServer.call(@name, {:state, state})
  end

  @spec stop() :: :ok
  def stop do
    GenServer.stop(@name)
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

  @spec gen_state() :: State.t
  def gen_state do
    advance(State.gen_state())
  end

  @spec timeout(non_neg_integer) :: non_neg_integer
  defp timeout(count) do
    if count < 50_000 do
      5000
    else
      trunc(count / 10)
    end
  end

end
