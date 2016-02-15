# Life

Naive implementation of the [Game of Life](https://en.wikipedia.org/wiki/Conway%27s_Game_of_Life "Conway's Game of Life").
Each cell is a [`gen_server`](http://erlang.org/doc/man/gen_server.html) implementation; there is no supervision tree.


### Try it out

Generate and run a grid with 10 rows and 15 columns:
```
iex> Life.kick_start { 10, 15 }
```

Generate and run a grid with 10 rows and 10 columns:
```
iex> Life.kick_start 10
```

### What it does

1. Generate the cells, assigning them a state at random (dead or alive)
2. Print the current states (red `X` means dead, green `O` means alive)
2. Compute and apply the new states for each cell according the rules of the game
3. If a loop is detected, then stop and print where it would loop. Otherwise, go to (2)

### Structure

One board to rule them all.

A cell state is represented by a tuple `{ coord, alive, neighbours }`, where:
* `coord` : the cell's coordinates, a tuple `{ x, y }`
* `alive` : if the cell's alive (`:true` or `:false`)
* `neighbours` : list of coordinates representing the cell's neighbours. If Elixir/Erlang had memoization like Haskell, this would not be necessary

The board maintain a hashmap of all the cells, the key being the cell's coordinates (`{ x, y }`) and the value being a tuple `{ pid, state }`, where:
* `pid` : the cell's processus id
* `state` : the cell's state, refreshed each time the clock ticks (stored so it can be reused for printing etc...)

### I know it's not there and I might or might not come back to do it

* Tests
* Supervision
* Use `Tasks` instead of dirty `spawn_link` for the parallel map
* Doc