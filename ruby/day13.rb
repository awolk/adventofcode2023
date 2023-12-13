require_relative './lib/aoc'

input = AOC.get_input(13)
grids = input.split("\n\n").map do |grid_s|
  grid_s.split.map(&:chars)
end

def count_differences(a, b)
  a.zip(b).sum do |a_row, b_row|
    a_row.zip(b_row).count {_1 != _2}
  end
end

def sum_reflection_rows(grid, expected_differences)
  (1 ... grid.length).select do |n|
    consider_on_each_side = [n, grid.length - n].min
    rows_before = grid[(n - consider_on_each_side) ... n]
    rows_after = grid[n ... (n + consider_on_each_side)]
    count_differences(rows_before, rows_after.reverse) == expected_differences
  end.sum
end

pt1 = grids.sum do |grid|
  100 * sum_reflection_rows(grid, 0) + sum_reflection_rows(grid.transpose, 0)
end
puts "Part 1: #{pt1}"

pt2 = grids.sum do |grid|
  100 * sum_reflection_rows(grid, 1) + sum_reflection_rows(grid.transpose, 1)
end
puts "Part 2: #{pt2}"