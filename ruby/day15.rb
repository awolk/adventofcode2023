require_relative './lib/aoc'

def hash(string)
  string.chars.reduce(0) do |acc, chr|
    ((acc + chr.ord) * 17) % 256
  end
end

input = AOC.get_input(15)

pt1 = input.split(",").sum(&method(:hash))
puts "Part 1: #{pt1}"

# Ruby hashes maintain insertion order
boxes = Array.new(256) {{}}
input.split(",").each do |command|
  /^(?<label>[a-z]+)(?<op>[-=])(?<lens>(\d+)?)$/ =~ command
  box = hash(label)
  if op == '-'
    boxes[box].delete(label)
  elsif op == '='
    boxes[box][label] = lens.to_i
  end
end

pt2 = boxes.each_with_index.sum do |box, box_index|
  box.values.each_with_index.sum do |lens, lens_index|
    (box_index + 1) * (lens_index + 1) * lens
  end
end
puts "Part 2: #{pt2}"