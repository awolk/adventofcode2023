require_relative './lib/aoc'
require_relative './lib/grid'
require_relative './lib/parser'

Rule = Struct.new(:category, :op, :threshold, :destination) do
  def matches?(part)
    part[category].public_send(op, threshold)
  end
end

Workflow = Struct.new(:name, :rules, :fallback) do
  def apply(part)
    rules.each do |rule|
      return rule.destination if rule.matches?(part)
    end
    fallback
  end
end

rule_parser = P.seq(P.word, P.regexp(/[<>]/).map(&:to_sym), P.int, ':', P.word).map do |category, op, threshold, destination|
  Rule.new(category, op, threshold, destination)
end
workflow_parser = P.seq(P.word, '{', rule_parser.delimited(','), ',', P.word, '}').map do |name, rules, fallback|
  Workflow.new(name, rules, fallback)
end
part_parser = P.str("{") >> P.seq(P.word, '=', P.int).delimited(',').map(&:to_h) << "}"
parser = P.seq(workflow_parser.each_line, "\n\n", part_parser.each_line)

input = AOC.get_input(19)
# input = AOC.get_example_input(19)
workflows, parts = parser.parse_all(input)
workflows_map = workflows.map {[_1.name, _1]}.to_h

pt1 = parts.sum do |part|
  workflow = 'in'
  while workflow != 'A' && workflow != 'R'
    workflow = workflows_map[workflow].apply(part)
  end
  workflow == 'A' ? part.values.sum : 0
end
puts "Part 1: #{pt1}"

pt2 = 0
puts "Part 2: #{pt2}"
