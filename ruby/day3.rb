require_relative './lib/aoc'

input = AOC.get_input(3)
rows = input.split("\n")

def each_neighbor(rows, r, c, &blk)
  [r-1, r, r+1].each do |ir|
    [c-1, c, c+1].each do |ic|
      next if ir == r && ic == c
      val = rows[ir]&.[](ic)
      next if val.nil?
      blk.call(val, ir, ic)
    end
  end
end

def adjacent_symbol?(rows, r, c)
  to_enum(:each_neighbor, rows, r, c).any? do |val, ir, ic|
    val != '.' && !val.match?(/\d/)
  end
end

def adjacent_gears(rows, r, c)
  to_enum(:each_neighbor, rows, r, c).filter_map do |val, ir, ic|
    [ir, ic] if val == '*'
  end
end

pt1 = 0
gears = {} # map of position to adjacent numbers

rows.each_with_index do |row, r|
  row.scan(/\d+/) do |match|
    col_s, col_e = $~.offset(0)
    col_range = col_s ... col_e
    val = match.to_i

    if col_range.any? {|c| adjacent_symbol?(rows, r, c)}
      pt1 += val
    end

    gear_positions = col_range.flat_map do |c|
      adjacent_gears(rows, r, c)
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