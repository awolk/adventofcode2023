require_relative './lib/aoc'
require_relative './lib/grid'
require_relative './lib/parser'

input = AOC.get_input(18)
# input = AOC.get_example_input(18)

parser = P.seq(P.word, ' ', P.int, ' (#', P.regexp(/[0-9a-f]+/), ')').each_line
steps = parser.parse_all(input)

dirs = {
  'R' => Vector[1, 0],
  'D' => Vector[0, -1],
  'L' => Vector[-1, 0],
  'U' => Vector[0, 1],
}

pos = Vector[0, 0]
edges = Set[pos]
steps.each do |dir, count, _color|
  count.times do
    pos += dirs[dir]
    edges << pos
  end
end

x_range = edges.map {_1[0]}.minmax
y_range = edges.map {_1[1]}.minmax

# flood fill from a non-edge corner
start = [
  Vector[x_range[0], y_range[0]],
  Vector[x_range[0], y_range[1]],
  Vector[x_range[1], y_range[0]],
  Vector[x_range[1], y_range[1]]
].find {|pos| !edges.include?(pos)}

# extend the edges to allow the flood fill to catch everything
x_range[0] -= 1
x_range[1] += 1
y_range[0] -= 1
y_range[1] += 1

filled = Set[]
to_visit = Set[start]
while !to_visit.empty?
  pos = to_visit.first
  to_visit.delete(pos)

  next if !pos[0].between?(*x_range) || !pos[1].between?(*y_range)
  next if filled.include?(pos)
  next if edges.include?(pos)
  filled << pos
  dirs.values.each do |dir|
    to_visit << pos + dir
  end
end

pt1 = (x_range[1] - x_range[0] + 1) * (y_range[1] - y_range[0] + 1) - filled.size
puts "Part 1: #{pt1}"


pt2 = 0
puts "Part 2: #{pt2}"
