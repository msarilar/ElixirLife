defmodule Life.Cell do

  use GenServer

  def tick(pid, cells) do
    GenServer.call(pid, { :tick, cells })
  end

  def apply(pid, alive) do
    GenServer.call(pid, { :apply, alive })
  end

  def alive?(pid) do
    GenServer.call(pid, :alive)
  end

  def start_link(coords, alive) do
    neighbours = Life.Util.neighbours_coordinates coords
    GenServer.start_link(__MODULE__, { coords, alive, neighbours })
  end

  def handle_call({ :tick, currentStates }, _, { coords, alive, neighbours }) do
    sum = Life.Util.pmap(neighbours, fn c -> currentStates[c] end)
      |> Enum.filter(fn a -> a != :nil end)
      |> Enum.filter(fn { _, s } -> s == :true end)
      |> Enum.count
      
    newAlive =
      case alive do
        :true   -> sum == 2 || sum == 3
        :false  -> sum == 3
      end
      
    { :reply, newAlive, { coords, alive, neighbours } }
  end

  def handle_call(:alive, _, { coords, alive, neighbours }) do
    { :reply, alive, { coords, alive, neighbours } }
  end

  def handle_call({ :apply, newAlive }, _, { coords, _, neighbours }) do
    { :reply, newAlive, { coords, newAlive, neighbours } }
  end

end