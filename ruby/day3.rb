require_relative './lib/aoc'
require_relative './lib/grid'

input = AOC.get_input(3)
grid = Grid.chars(input)

def adjacent_symbol?(grid, r, c)
  grid.neighbors_with_positions(r, c).any? do |val, _pos|
    val != '.' && !val.match?(/\d/)
  end
end

def adjacent_gears(grid, r, c)
  grid.neighbors_with_positions(r, c).filter_map do |val, pos|
    pos if val == '*'
  end
end

pt1 = 0
gears = {} # map of position to adjacent numbers

grid.row_strings.each_with_index do |row, r|
  row.scan(/\d+/) do |match|
    col_s, col_e = $~.offset(0)
    col_range = col_s ... col_e
    val = match.to_i

    if col_range.any? {|c| adjacent_symbol?(grid, r, c)}
      pt1 += val
    end

    gear_positions = col_range.flat_map do |c|
      adjacent_gears(grid, r, c)
    end.uniq
    gear_positions.each do |gear|
      (gears[gear] ||= []) << val
    end
  end
end

pt2 = gears.values.filter_map do |numbers|
  numbers.reduce(:*) if numbers.length == 2
end.sum

puts "Part 1: #{pt1}"
puts "Part 2: #{pt2}"