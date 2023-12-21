require_relative './lib/aoc'
require_relative './lib/grid'
require_relative './lib/parser'

input = AOC.get_input(21)
# input = AOC.get_example_input(21)

grid = Grid.chars(input)
start = grid.index('S')

positions = Set[start]
new_positions = Set[]
64.times do
  positions.each do |position|
    grid.neighbors_with_positions(position, diagonals: false).each do |val, np|
      new_positions << np if val != '#'
    end
  end
  positions = new_positions
  new_positions = Set[]
end


pt1 = positions.size
puts "Part 1: #{pt1}"

pt2 = 0
puts "Part 2: #{pt2}"
