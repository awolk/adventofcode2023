require_relative './lib/aoc'

def expand_rows(grid)
  res_rows = []
  grid.to_a.each do |row|
    res_rows << row
    res_rows << row if row.all?('.')
  end
  Matrix.rows(res_rows)
end

input = AOC.get_input(11)
grid = AOC.char_matrix(input)
grid = expand_rows(grid)
grid = expand_rows(grid.transpose).transpose

positions = grid.each_with_index.filter_map do |val, r, c|
  [r, c] if val == '#'
end

pt1 = positions.combination(2).sum do |((r1, c1), (r2, c2))|
  (r1 - r2).abs + (c1 - c2).abs
end

puts "Part 1: #{pt1}"
pt2 = 0
puts "Part 2: #{pt2}"