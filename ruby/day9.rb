require_relative './lib/aoc'

def next_and_prev_value(sequence)
  stages = [sequence]
  while !stages.last.all?(0)
    stages << stages.last.each_cons(2).map {_2 - _1}
  end

  next_val = stages.sum(&:last)
  prev_val = 0
  stages.reverse.each do |stage|
    prev_val = -prev_val + stage.first
  end

  [next_val, prev_val]
end

input = AOC.get_input(9)
sequences = input.split("\n").map {|line| line.split.map(&:to_i)}

res = sequences.map {|seq| next_and_prev_value(seq)}

pt1 = res.sum(&:first)
puts "Part 1: #{pt1}"
pt2 = res.sum(&:last)
puts "Part 2: #{pt2}"