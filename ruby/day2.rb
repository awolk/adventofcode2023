require_relative './lib/aoc'
require_relative './lib/parser'

Hand = Struct.new(:red, :green, :blue)
Game = Struct.new(:id, :hands) do
  def possible?(red:, green:, blue:)
    hands.all? do |hand|
      hand.red <= red && hand.green <= green && hand.blue <= blue
    end
  end

  def power
    min_red = hands.map(&:red).max
    min_green = hands.map(&:green).max
    min_blue = hands.map(&:blue).max
    min_red * min_green * min_blue
  end
end

hand_parser = P.seq(P.int, ' ', P.word).delimited(', ').map do |hand|
  red = hand.find {|count, color| color == 'red'}&.first || 0
  green = hand.find {|count, color| color == 'green'}&.first || 0
  blue = hand.find {|count, color| color == 'blue'}&.first || 0
  Hand.new(red, green, blue)
end
game_parser = P.seq('Game ', P.int, ': ', hand_parser.delimited('; ')).map do |id, hands|
  Game.new(id, hands)
end
parser = game_parser.each_line

games = parser.parse_all(AOC.get_input(2))

pt1 = games.select do |game|
  game.possible?(red: 12, green: 13, blue: 14)
end.sum(&:id)
puts "Part 1: #{pt1}"

pt2 = games.sum(&:power)
puts "Part 2: #{pt2}"