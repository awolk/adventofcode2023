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

# Simulate bricks falling
directly_above = {}
directly_below = {}

bricks.sort_by!(&:high_z)
bricks.each_with_index do |brick, ind|
  below_with_ind = bricks[...ind].each_with_index.select {|other_brick, _| other_brick.overlapping_vertical?(brick)}
  highest_below = below_with_ind.map {_1[0].high_z}.max
  brick.fall_to!((highest_below || 0) + 1)

  directly_below_ind = below_with_ind.select {|other_brick, ind| other_brick.high_z == highest_below}.map(&:last)
  (directly_below[ind] ||= Set[]).merge(directly_below_ind)
  directly_below_ind.each do |dbi|
    (directly_above[dbi] ||= Set[]).add(ind)
  end
end

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