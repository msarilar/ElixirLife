defmodule Life.Util do

  def cartesian list do
    for i <- list, j <- list, do: { i, j }
  end

  def apply_mod { x, y }, x_mod, y_mod do
    { x + x_mod, y + y_mod }
  end

  def split(list, lineCount) do
    case list do
      { a, [] } -> [a]
      { a, b }  -> [a] ++ split(Enum.split(b, lineCount), lineCount)
      a         -> split(Enum.split(a, lineCount), lineCount)
    end
  end
  
  def hash boolArray do
    Enum.reduce(boolArray, 29, fn(bool, result) -> 
      case bool do
        :true  -> (result + 1) * 23
        :false -> result * 23
      end
    end)
  end

  def neighbours_coordinates { x, y } do
    Enum.map(0..2, fn x -> x - 1 end)
      |> Life.Util.cartesian
      |> Enum.map(&(Life.Util.apply_mod &1, x, y))
      |> Enum.filter(fn { x, y } -> x >= 0 && y >= 0 end)
      |> Enum.filter(fn { nx, ny } -> { nx, ny } != { x, y } end)
  end

  def pmap(collection, function) do
    current = self
    collection
      |> Enum.map(fn (elem) -> spawn_link fn -> (send current, { self, function.(elem) }) end end) 
      |> Enum.map(fn (_) -> receive do { _, result } -> result end end)
  end
  
  def flatten_states states do
    Life.Util.hash Enum.sort(states)
      |> Enum.map(fn { _, { _, s } } -> s end)
  end
  
  def print_cells cells, lineCount do
    pretty = Enum.sort(cells)
      |> Enum.map(fn { _, { _, s } } -> s end)
      |> Enum.map(fn s  ->
          case s do
              :true -> "\e[32mO"
              :false -> "\e[31mX"
          end
        end)

    text = Life.Util.split(pretty, lineCount)
      |> Enum.map(fn line -> Enum.reduce(line, "", fn(item, text) -> text <> item end) end)
      |> Enum.reduce("", fn(item, text) -> text <> item <> "\n" end)
      
    IO.puts text <> "\e[39m"
    
    :ok
  end
  
end