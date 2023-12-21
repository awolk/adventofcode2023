require_relative './lib/aoc'
require_relative './lib/grid'
require_relative './lib/parser'

input = AOC.get_input(21)
# input = AOC.get_example_input(21)
grid = Grid.chars(input)

def unique_positions(grid, after_steps)
  start = grid.index('S')
  positions = Set[start]
  new_positions = Set[]
  [0, *after_steps].each_cons(2).map {_2 - _1}.map do |delta|
    delta.times do
      positions.each do |(r, c)|
        [[r+1, c], [r-1, c], [r, c+1], [r, c-1]].each do |nr, nc|
          if grid[nr % grid.row_count, nc % grid.column_count] != '#'
            new_positions << [nr, nc]
          end
        end
      end
      positions = new_positions
      new_positions = Set[]
    end

    positions.length
  end
end

pt1 = unique_positions(grid, [64]).first
puts "Part 1: #{pt1}"

def extrapolate_quadratic(f0, f1, f2, x)
  # f(x) = a*x*x + b*x + c
  c = f0
  a = (f2 - 2 * f1 + f0) / 2
  b = 2 * f1 - (3 * f0 + f2) / 2
  a*x*x + b*x + c
end

# w = width of original grid
# f(n) = number of unique possible positions after n steps
# g(n) = f(o + w*n) where o is some fixed offset
# Turns out g(n) is quadratic, and so we derive a quadratic form
n = 26501365
w = grid.row_count
o = n % w
# calculate g(0), g(1), g(2) = f(o), f(o + w), f(o + 2*w)
g0, g1, g2 = unique_positions(grid, [o, o + w, o + 2 * w])
pt2 = extrapolate_quadratic(g0, g1, g2, n / w)
puts "Part 2: #{pt2}"