require_relative './lib/aoc'
require_relative './lib/grid'
require_relative './lib/parser'

def dist((r1, c1), (r2, c2))
  (r1 - r2).abs + (c1 - c2).abs
end

def diff(pos1, pos2)
  return nil if pos1.nil? || pos2.nil?
  r1, c1 = pos1
  r2, c2 = pos2
  [r1 - r2, c1 - c2]
end

input = AOC.get_input(17)
# input = AOC.get_example_input(17)
grid = Grid.digits(input)

def reconstruct_path(came_from, current)
  path = [current]
  while came_from.has_key?(current)
    current = came_from[current]
    path.unshift(current)
  end
  return path
end

def a_star(grid)
  start = [0, 0]
  goal = [grid.row_count-1, grid.column_count-1]

  first_state = [start, 0, [0, 0]]
  open_set = Set[first_state]
  came_from = {}
  # states in the graph record [position, last n steps in same dir, dir]
  gscore = {first_state => 0}
  fscore = {first_state => dist(start, goal)}

  while !open_set.empty?
    current = open_set.min_by(&fscore)
    if current[0] == goal
      # return reconstruct_path(came_from, current)
      return gscore[current]
    end

    open_set.delete(current)
    pos, last_n_steps, last_dir = current
    grid.neighbors_with_positions(pos, diagonals: false).each do |cost, neighbor|
      dir = diff(neighbor, pos)
      next if dir[0] == -last_dir[0] && dir[1] == -last_dir[1] # no turning backwards
      if dir == last_dir
        next if last_n_steps == 3
        steps = last_n_steps + 1
      else
        steps = 1
      end
      neighbor_entry = [neighbor, steps, dir]

      tentative_g_score = gscore[current] + cost
      if gscore[neighbor_entry].nil? || tentative_g_score < gscore[neighbor_entry]
        came_from[neighbor_entry] = current
        gscore[neighbor_entry] = tentative_g_score
        fscore[neighbor_entry] = tentative_g_score + dist(neighbor, goal)
        open_set.add(neighbor_entry)
      end
    end
  end

  raise "could not reach goal"
end

pt1 = a_star(grid)
puts "Part 1: #{pt1}"

pt2 = 0
puts "Part 2: #{pt2}"
