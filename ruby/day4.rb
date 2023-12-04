require_relative './lib/aoc'
require_relative './lib/parser'

input = AOC.get_input(4)

int_set = P.int.delimited(P.whitespace).map(&:to_set)
parser = (P.regexp(/Card +\d+: +/) >> int_set & P.regexp(/ +\| +/) >> int_set).each_line

card_matches = parser.parse_all(input).map do |winning_set, numbers|
  (winning_set & numbers).length
end


pt1 = card_matches.sum do |n|
  if n == 0
    0
  else
    2 ** (n - 1)
  end
end
puts "Part 1: #{pt1}"


sums = Array.new(card_matches.length, 1)

card_matches.each_with_index do |n, index|
  ((index + 1)  .. [index + n, card_matches.length - 1].min).each do |earned|
    sums[earned] += sums[index]
  end
end

pt2 = sums.sum
puts "Part 2: #{pt2}"