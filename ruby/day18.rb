require_relative './lib/aoc'
require_relative './lib/parser'

def area(steps)
  vertices = steps.reduce([Vector[0, 0]]) do |vertices, step|
    vertices << vertices.last + step
  end

  # Shoelace formula calculates the area enclosed by points within the center
  # of a given square (A').
  # Pick's theorem gives us that A' = i + b/2 - 1 for that offset polygon, where
  # b is the points on the perimeter and i is the number of internal squares.
  # We therefore have i = A' - b/2 + 1
  # Area of the entire thing is the internal squares and the perimeter squares.
  # A = i + b = A' + b/2 + 1
  b = steps.sum(&:magnitude)

  a_prime = vertices.each_cons(2).sum do |a, b|
    a[0] * b[1] - b[0] * a[1]
  end.abs / 2
  
  (a_prime + b / 2 + 1).to_i
end

dirs = {
  'R' => Vector[1, 0],
  'D' => Vector[0, -1],
  'L' => Vector[-1, 0],
  'U' => Vector[0, 1],
}

input = AOC.get_input(18)
pt1_parser = P.seq(P.word.map(&dirs), ' ', P.int).map {|dir, len| dir * len}
pt2_parser = P.regexp(/[0-9a-f]+/).map do |color|
  color[...5].to_i(16) * dirs.values[color[5].to_i]
end
parser = P.seq(pt1_parser, ' (#', pt2_parser, ')').each_line
steps = parser.parse_all(input)

pt1 = area(steps.map(&:first))
puts "Part 1: #{pt1}"

pt2 = area(steps.map(&:last))
puts "Part 2: #{pt2}"
