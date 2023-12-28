require_relative './lib/aoc'
require_relative './lib/parser'

def group(combinations)
  connects_to = {}
  combinations.each do |a, b|
    (connects_to[a] ||= Set[]) << b
    (connects_to[b] ||= Set[]) << a
  end
  
  res = []
  nodes = combinations.to_a.flatten.uniq
  while !nodes.empty?
    node = nodes.pop
    new_group = Set[node]
    to_visit = connects_to[node]
    while !to_visit.empty?
      next_to_visit = Set[]
      to_visit.each do |visiting|
        next if !nodes.include?(visiting)
        nodes.delete(visiting)
        new_group << visiting
        next_to_visit += (connects_to[visiting] - new_group)
      end
      to_visit = next_to_visit
    end

    res << new_group
  end
  res
end

input = AOC.get_input(25)
parser = P.seq(P.word, ': ', P.word.delimited(' ')).each_line
components = parser.parse_all(input)

connections = components.flat_map do |a, bs|
  bs.map {|b| [a, b]}
end

# To generate graphviz chart:
# puts "graph {"
# connections.each do |a, b|
#   puts "#{a} -- #{b}"
# end
# puts "}"

# Edges determined from Graphviz chart
to_sever = [['vps', 'pzc'], ['xvk', 'sgc'], ['dph', 'cvx']]
severed = connections - (to_sever + to_sever.map(&:reverse))
pt1 = group(severed).map(&:size).reduce(:*)
puts "Part 1: #{pt1}"