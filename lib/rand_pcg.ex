defmodule RandPCG do
  @moduledoc """
  Generate random numbers based on the [PCG Algorithm](http://www.pcg-random.org)
  """
  use Application
  use RandPCG.Bitwise

  @name RandPCG.Worker

  def start(args \\ []), do: start(nil, args)
  def start(type, nil), do: start(type, [])
  def start(_type, args) do
    import Supervisor.Spec, warn: false

    opts = args
           |> Keyword.take([:seed, :inc])
           |> Keyword.put(:name, @name)

    children = [
      worker(RandPCG.Worker, [opts]),
    ]

    opts = [strategy: :one_for_one, name: RandPCG.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @doc """
  Returns a random 32bit integer
  ## Examples
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

  @spec timeout(non_neg_integer) :: non_neg_integer
  defp timeout(count) do
    if count < 50_000 do
      5000
    else
      trunc(count / 10)
    end
  end

end
