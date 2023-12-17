require_relative './lib/aoc'
require_relative './lib/grid'
require_relative './lib/parser'

def diff(pos1, pos2)
  r1, c1 = pos1
  r2, c2 = pos2
  [r1 - r2, c1 - c2]
end

class Graph
  def initialize(grid, min_steps_after_turn, max_steps_in_same_dir)
    @grid = grid
    @min_steps_after_turn = min_steps_after_turn
    @max_steps_in_same_dir = max_steps_in_same_dir
    @goal = [grid.row_count - 1, grid.column_count - 1]
  end

  def goal?(state)
    state[0] == @goal
  end

  def heuristic(state)
    (r, c), = state
    @grid.row_count - r + @grid.column_count - c - 2
  end

  def neighbors_with_cost(state)
    pos, last_n_steps, last_dir = state
    dirs = [[0, 1], [0, -1], [1, 0], [-1, 0]]
    dirs.delete([-last_dir[0], -last_dir[1]])
    dirs.delete(last_dir) if last_n_steps == @max_steps_in_same_dir
    dirs.filter_map do |dir|
      if dir != last_dir
        # we turned, so go minimum inital steps
        new_pos = [pos[0] + @min_steps_after_turn*dir[0], pos[1] + @min_steps_after_turn*dir[1]]
        next nil if !@grid.valid_pos?(new_pos)
        cost = (1..@min_steps_after_turn).sum {|n| @grid[pos[0] + n*dir[0], pos[1] + n*dir[1]]}
        [[new_pos, @min_steps_after_turn, dir], cost]
      else
        new_pos = [pos[0] + dir[0], pos[1] + dir[1]]
        next nil if !@grid.valid_pos?(new_pos)
        [[new_pos, last_n_steps + 1, dir], @grid[new_pos]]
      end
    end
  end
end

# input = AOC.get_input(17)
input = AOC.get_example_input(17)
grid = Grid.digits(input)

def a_star(start, graph)
  open_set = Set[start]
  gscore = {start => 0}
  fscore = {start => graph.heuristic(start)}

  while !open_set.empty?
    current = open_set.min_by(&fscore)
    if graph.goal?(current)
      return gscore[current]
    end

    open_set.delete(current)

    graph.neighbors_with_cost(current).each do |neighbor, cost|
      tentative_gscore = gscore[current] + cost
      if gscore[neighbor].nil? || tentative_gscore < gscore[neighbor]
        gscore[neighbor] = tentative_gscore
        fscore[neighbor] = tentative_gscore + graph.heuristic(neighbor)
        open_set.add(neighbor)
      end
    end
  end

  raise "could not reach goal"
end

pt1 = a_star([[0, 0], 0, [0, 0]], Graph.new(grid, 1, 3))
puts "Part 1: #{pt1}"

pt2 = a_star([[0, 0], 0, [0, 0]], Graph.new(grid, 4, 10))
puts "Part 2: #{pt2}"
