require_relative './lib/aoc'
require_relative './lib/grid'

Beam = Struct.new(:pos, :dir) do
  def r = pos[0]
  def c = pos[1]
  def dr = dir[0]
  def dc = dir[1]

  def next = Beam.new([r + dr, c + dc], dir)
end

def count_energized(grid, initial_beam)
  energized = Set[]
  handled = Set[]
  beams = [initial_beam]

  while !beams.empty?
    new_beams = []
    beams.each do |beam|
      next if handled.include?(beam)
      handled << beam

      next_step = beam.next
      next unless grid.valid_pos?(next_step.pos)
      energized << next_step.pos

      at = grid[next_step.pos]
      case at
      when '.'
        new_beams << next_step
      when '|'
        if next_step.dr.zero?
          new_beams << Beam.new(next_step.pos, [1, 0])
          new_beams << Beam.new(next_step.pos, [-1, 0])
        else
          new_beams << next_step
        end
      when '-'
        if next_step.dc.zero?
          new_beams << Beam.new(next_step.pos, [0, 1])
          new_beams << Beam.new(next_step.pos, [0, -1])
        else
          new_beams << next_step
        end
      when '/'
        new_beams << Beam.new(next_step.pos, [-next_step.dc, -next_step.dr])
      when '\\'
        new_beams << Beam.new(next_step.pos, [next_step.dc, next_step.dr])
      end
    end
    beams = new_beams
  end

  energized.size
end

input = AOC.get_input(16)
grid = Grid.chars(input)

pt1 = count_energized(grid, Beam.new([0, -1], [0, 1]))
puts "Part 1: #{pt1}"

starting_beams = []
(0...grid.column_count).each do |c|
  starting_beams << Beam.new([-1, c], [1, 0])
  starting_beams << Beam.new([grid.row_count, c], [-1, 0])
end
(0...grid.row_count).each do |r|
  starting_beams << Beam.new([r, -1], [0, 1])
  starting_beams << Beam.new([r, grid.column_count], [0, -1])
end

pt2 = starting_beams.map do |beam|
  count_energized(grid, beam)
end.max
puts "Part 2: #{pt2}"