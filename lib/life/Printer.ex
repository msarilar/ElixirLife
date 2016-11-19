defmodule Life.Printer do
  use GenServer
  
  def print(cells, lineCount, gen) do
    GenServer.cast(:printer, { :print, { cells, lineCount, gen } })
  end
  
  def print_end(gen, dupIndex) do
    GenServer.cast(:printer, { :print_end, { gen, dupIndex } })
  end

  def start_link do
    GenServer.start_link(__MODULE__, :nil, name: :printer)
  end
  
  def handle_cast( {:print_end, { gen, dupIndex } }, :nil) do
    IO.puts "\e[41mLoop to Generation " <> Integer.to_string(gen - dupIndex) <> "\e[m"
    
    {:noreply, :nil}
  end
  
  def handle_cast( {:print, { cells, lineCount, gen } }, :nil) do
    # IO.write [IO.ANSI.home, IO.ANSI.clear]
  
    IO.puts "\e[35m Generation " <> Integer.to_string(gen) <> "\e[39m"
      
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
      
    IO.puts "\r\n" <> text <> "\e[39m"
    
    {:noreply, :nil}
  end
  
end