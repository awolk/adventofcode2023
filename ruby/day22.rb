require_relative './lib/aoc'
require_relative './lib/grid'
require_relative './lib/parser'

def range_intersect?(a, b)
  a.include?(b.first) || b.include?(a.first)
end

class Brick
  def initialize(a, b)
    @a = Vector[*a.zip(b).map(&:min)]
    @b = Vector[*a.zip(b).map(&:max)]
  end
  attr_reader :a, :b

  def low_z = a[2]
  def high_z = b[2]

  def overlapping_vertical?(other)
    (0..1).all? {|dim| range_intersect?(a[dim] .. b[dim], other.a[dim] .. other.b[dim])}
  end

  def fall_to!(z)
    dist = a[2] - z
    @a -= Vector[0, 0, dist]
    @b -= Vector[0, 0, dist]
  end
end

input = AOC.get_input(22)
bricks = input.split("\n").map do |line|
  Brick.new(*line.split('~').map {|part| Vector[*part.split(',').map(&:to_i)]})
end

# Find bricks that are above/below one another
below = {}
above = {}
(0...bricks.length).to_a.combination(2).each do |b1, b2|
  next unless bricks[b1].overlapping_vertical?(bricks[b2])
  b1, b2 = [b1, b2].sort_by {|ind| bricks[ind].low_z}
  # b1 is below b2
  (above[b1] ||= []) << b2
  (below[b2] ||= []) << b1
end

# Simulate bricks falling
some_below, none_below = (0...bricks.length).partition(&below)
none_below.each do |i|
  bricks[i].fall_to!(1)
end
some_below.sort_by! {bricks[_1].low_z}
some_below.each do |i|
  fall_to = below[i].map {|bi| bricks[bi].high_z}.max + 1
  bricks[i].fall_to!(fall_to)
end

# Categorize bricks as safe or unsafe
directly_above = above.map do |i, all_above|
  [i, all_above.filter {|ai| bricks[ai].low_z == bricks[i].high_z + 1}.to_set]
end.to_h
directly_below = below.map do |i, all_below|
  [i, all_below.filter {|bi| bricks[bi].high_z + 1 == bricks[i].low_z}.to_set]
end.to_h

unsafe, safe = (0...bricks.length).partition do |i|
  potentially_supports = directly_above.fetch(i, [])
  potentially_supports.any? do |potentially_supporting|
    directly_below[potentially_supporting]&.length == 1
  end
end

pt1 = safe.length
puts "Part 1: #{pt1}"

pt2 = unsafe.sum do |ind_to_disintegrate|
  # Find all of the affected bricks
  all_would_fall = Set[ind_to_disintegrate]
  falling = Set[ind_to_disintegrate]
  will_fall = Set[]
  loop do
    falling.each do |ind|
      # look for anything above that would've been supported but now isn't
      will_fall += directly_above.fetch(ind, []).select do |potentially_falling|
        possible_supporters = directly_below.fetch(potentially_falling, Set[]) - all_would_fall
        possible_supporters.empty?
      end
    end
    break if will_fall.empty?
    all_would_fall += will_fall
    falling = will_fall
    will_fall = Set[]
  end
  all_would_fall.size - 1
end
puts "Part 2: #{pt2}"