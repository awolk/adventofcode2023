require_relative './lib/aoc'

lines = AOC.get_input(1).split

pt1 = lines.sum do |line|
  digits = line.chars.filter { _1.match?(/[0-9]/)}
  digits.first.to_i * 10 + digits.last.to_i
end
puts "Part 1: #{pt1}"


digits = {'one' => 1, 'two' => 2, 'three' => 3, 'four' => 4, 'five' => 5, 'six' => 6, 'seven' => 7, 'eight' => 8, 'nine' => 9}
forward_re = /#{digits.keys.join('|')}|[0-9]/
backwards_re = /#{digits.keys.map(&:reverse).join('|')}|[0-9]/

pt2 = lines.sum do |line|
  first = line.match(forward_re).to_s
  first = digits[first] || first.to_i

  last = line.reverse.match(backwards_re).to_s.reverse
  last = digits[last] || last.to_i
  first * 10 + last
end
puts "Part 2: #{pt2}"