require_relative './lib/aoc'

class Image
  def initialize(grid)
    @empty_rows = (0 ... grid.row_count).select do |row_index|
      grid[row_index, 0..].all?('.')
    end.to_set
    @empty_cols = (0 ... grid.column_count).select do |column_index|
      (0...grid.row_count).all? {|r| grid[r, column_index] == '.'}
    end.to_set
    @galaxies = grid.each_with_index.filter_map do |val, r, c|
      [r, c] if val == '#'
    end
  end

  def sum_path_lengths(expansion)
    @galaxies.combination(2).sum do |((r1, c1), (r2, c2))|
      r1, r2 = [r1, r2].sort
      c1, c2 = [c1, c2].sort
      
      row_dist = r2 - r1 + (expansion - 1) * (@empty_rows & (r1 .. r2)).size
      col_dist = c2 - c1 + (expansion - 1) * (@empty_cols & (c1 .. c2)).size
      row_dist + col_dist
    end
  end
end

input = AOC.get_input(11)
image = Image.new(AOC.char_matrix(input))

pt1 = image.sum_path_lengths(2)
puts "Part 1: #{pt1}"

pt2 = image.sum_path_lengths(1000000)
puts "Part 2: #{pt2}"