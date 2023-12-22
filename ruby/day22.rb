require_relative './lib/aoc'
require_relative './lib/grid'
require_relative './lib/parser'

def range_intersect?(a, b)
  a.include?(b.first) || b.include?(a.first)
end

class Brick
  def initialize(a, b)
    @a = Vector[*(0..2).map {|dim| [a[dim], b[dim]].min}]
    @b = Vector[*(0..2).map {|dim| [a[dim], b[dim]].max}]
  end
  attr_reader :a, :b

  def low_z = a[2]
  def high_z = b[2]

  def overlapping_vertical?(other)
    (0..1).all? {|dim| range_intersect?(a[dim] .. b[dim], other.a[dim] .. other.b[dim])}
  end

  def at_ground? = low_z == 1

  def fall_to!(z)
    dist = @a[2] - z
    @a -= Vector[0, 0, dist]
    @b -= Vector[0, 0, dist]
  end
end

input = AOC.get_input(22)
# input = AOC.get_example_input(22)
bricks = input.split("\n").map do |line|
  Brick.new(*line.split('~').map {|part| Vector[*part.split(',').map(&:to_i)]})
end

below = {}
above = {}
(0...bricks.length).to_a.combination(2).each do |b1, b2|
  next unless bricks[b1].overlapping_vertical?(bricks[b2])
  b1, b2 = [b1, b2].sort_by {|ind| bricks[ind].low_z}
  # b1 is below b2
  (above[b1] ||= []) << b2
  (below[b2] ||= []) << b1
end

puts "found stacks"

fixed = Set[]
loop do
  any_moved = false
  bricks.each_with_index do |brick, i|
    next if fixed.include?(i)
    next if brick.at_ground?
    if below.key?(i)
      # move it until its directly above the brick below it
      fall_to = below[i].map {|bi| bricks[bi].high_z}.max + 1
      if fall_to != brick.low_z
        brick.fall_to!(fall_to)
        any_moved = true
      end
    else
      # nothing below, move it straight to the ground!
      brick.fall_to!(1)
      any_moved = true
      fixed << i
    end
  end
  break unless any_moved
end

puts "done simulating"

pt1 = bricks.each_with_index.count do |brick, i|
  potentially_supports = (above[i] || []).filter {bricks[_1].low_z == brick.high_z + 1}
  others_will_fall = potentially_supports.any? do |potentially_supporting|
    below_ps = below[potentially_supporting]
    other_below = below_ps.reject {_1 == i}
    highest_of_other_below = other_below.map {bricks[_1].high_z}.max
    highest_of_other_below != brick.high_z
  end
  !others_will_fall
end
puts "Part 1: #{pt1}"

pt2 = 0
puts "Part 2: #{pt2}"
