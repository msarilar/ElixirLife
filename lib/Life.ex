defmodule Life do
  
  def kick_start states do
    Life.Printer.start_link
    { cells, lineCount } =  generate_cells states
    current = Life.Util.flatten_states current_states cells
    
    tick_until_stale_loop { cells, lineCount, 0}, [current], :false
  end
  
  defp tick_until_stale_loop _, _, :true do
    :ok
  end
  
  defp tick_until_stale_loop { cells, lineCount, gen}, last, :false do
    Life.Printer.print cells, lineCount, gen
    
    cells = tick cells
    
    current = Life.Util.flatten_states cells
    
    dupIndex = Enum.find_index(last, fn item -> item == current end)
    
    stop = case dupIndex do
      :nil -> :false
      _    -> :true
    end
    
    if dupIndex != :nil do
      Life.Printer.print_end gen, dupIndex
    end
    
    tick_until_stale_loop { cells, lineCount, gen + 1 }, [current|last], stop
  end

  defp current_states cells do
    Life.Util.pmap(cells, fn { a, { pid, _ } } -> { a, { pid, Life.Cell.alive?(pid) } } end)
      |> Enum.into(%{})
  end

  defp tick cells do
    currentStates = current_states cells
    
    Life.Util.pmap(cells, fn { a, { pid, _ } } -> { a, { pid, Life.Cell.tick(pid, currentStates) } } end)
      |> Life.Util.pmap(fn { a, { pid, s } } -> { a, { pid, Life.Cell.apply(pid, s) } } end)
      |> Enum.into(%{})
  end

  defp generate_cells states do
    :random.seed(:os.timestamp)
    
    case states do
      { x, y } -> generate_from_tuple { x, y }
      count    -> generate_from_count count - 1
    end
  end
  
  defp generate_from_tuple { x, y } do
    list = for i <- 0..(x - 1), j <- 0..(y - 1), do: { i, j }
    list = list
      |> Enum.map(fn coords -> { coords, :random.uniform < 0.5 } end)
      |> Life.Util.pmap(fn { coords, state } -> { coords, { elem(Life.Cell.start_link(coords, state), 1), state } } end)
      |> Enum.into(%{})
      
    { list, y }
  end

  defp generate_from_count count do
    range = 0..count 
      |> Life.Util.cartesian
      |> Enum.map(fn coords -> { coords, :random.uniform < 0.5 } end)
      |> Life.Util.pmap(fn { coords, state } -> { coords, { elem(Life.Cell.start_link(coords, state), 1), state } } end)
      |> Enum.into(%{})
    
    { range, count + 1 }
  end

end