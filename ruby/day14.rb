require_relative './lib/aoc'
require_relative './lib/grid'

def slide!(grid, dr, dc)
  loop do
    changed = false
    grid.all_indexes('O').each do |r, c|
      ar, ac = r + dr, c + dc
      next unless grid.valid_pos?(ar, ac) && grid[ar, ac] == '.'

      changed = true
      grid[ar, ac] = 'O'
      grid[r, c] = '.'
    end
    break if !changed
  end
end

def cycle!(grid)
  slide!(grid, -1, 0)
  slide!(grid, 0, -1)
  slide!(grid, 1, 0)
  slide!(grid, 0, 1)
end

def total_load(grid)
  grid.all_indexes('O').sum do |r, _c|
    grid.row_count - r
  end
end

# returns the offset from the start and the cycle
def find_repeating_cycle(&blk)
  all_values = [blk.call]
  loop do
    all_values << blk.call
    (1 .. (all_values.length / 2)).each do |potential_length|
      last_values = all_values[-potential_length ..]
      before_that = all_values[-potential_length * 2 ... -potential_length]
      if last_values == before_that
        return [all_values.length - potential_length * 2, last_values]
      end
    end
  end
end

input = AOC.get_input(14)
grid = Grid.chars(input)

pt1_grid = grid.clone
slide!(pt1_grid, -1, 0)
pt1 = total_load(pt1_grid)
puts "Part 1: #{pt1}"

offset, cycle = find_repeating_cycle do
  cycle!(grid)
  total_load(grid)
end
pt2 = cycle[(1000000000 - offset - 1) % cycle.length]
puts "Part 2: #{pt2}"