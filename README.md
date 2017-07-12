# RandPCG

A random number generator using the [PCG](http://www.pcg-random.org/) algorithm.

Documentation: https://hexdocs.pm/rand_pcg/

## Installation

  1. Add `rand_pcg` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:rand_pcg, "~> 0.1.2"}]
    end
    ```

  2. If you are using the GenServer option, ensure `rand_pcg` is started before
   your application:

    ```elixir
    def application do
      [applications: [:rand_pcg]]
    end
    ```

## Examples

### GenServer Option

#### Get Some Random

```elixir
# Random 32 bit integer
RandPCG.random()

# Random 32 bit based float
RandPCG.random(:float)

# n Random 32 bit integers
RandPCG.random(n)

# Random nth of an enumerable
list = [:a, :b, :c]
RandPCG.random(list)

# Random integer x where min <= x <= max
RandPCG.random(min, max)

# n random integers x where min <= x <= max
RandPCG.random(min, max, n)
```

#### Set State

```elixir
state = %RandPCG.State{seed: 234532454323451, inc: 1}
RandPCG.state(state)
```

#### Note

The initial seed is based on `:os.system_time(:micro_seconds)`

### Without running the GenServer

You will have to maintain your own state of the random number generator.

#### Random 32 bit Integer

```elixir
state = RandPCG.PCG.gen_state()
random_int_32 = RandPCG.PCG.xsh_rr(state)
state = advance(state)
```

If you do not advance the state, you will receive the same random number.

#### Random Integer in a Range

```elixir
state = RandPCG.PCG.gen_state()
min = 1
max = 10
random_1_10_inclusive = RandPCG.PCG.rand_int(min, max, state)
state = advance(state)
```

`RandPCG.PCG.gen_state` initial seed is based on `:os.system_time(:micro_seconds)`

## References

- [PCG Random Number Generator Homepage](http://www.pcg-random.org/)
- [PCG Basic C Implementation](https://github.com/imneme/pcg-c-basic)
- [PCG Go Implementation](https://github.com/dgryski/go-pcgr) was also helpful
