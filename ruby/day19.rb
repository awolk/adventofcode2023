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

rule_parser = P.seq(P.word, P.regexp(/[<>]/).map(&:to_sym), P.int, ':', P.word).map do |args|
  Rule.new(*args)
end
workflow_parser = P.seq(P.word, '{', rule_parser.delimited(','), ',', P.word, '}').map do |args|
  Workflow.new(*args)
end
part_parser = P.str("{") >> P.seq(P.word, '=', P.int).delimited(',').map(&:to_h) << "}"
parser = P.seq(workflow_parser.each_line, "\n\n", part_parser.each_line)

input = AOC.get_input(19)
workflows, parts = parser.parse_all(input)
workflows_map = workflows.to_h {[_1.name, _1]}

pt1 = parts.sum do |part|
  workflow = 'in'
  while workflow != 'A' && workflow != 'R'
    workflow = workflows_map[workflow].apply(part)
  end
  workflow == 'A' ? part.values.sum : 0
end
puts "Part 1: #{pt1}"


# go through every workflow path possible, and then for each path determine the possible ranges of values
# returns a list of lists of [category, range] for accepted conditions
def paths(position, workflows_map)
  return [] if position == 'R'
  return [[]] if position == 'A'

  res = []

  workflow = workflows_map[position]
  inverted_conditions = []
  workflow.rules.each do |rule|
    if rule.op == :<
      range = 1 ... rule.threshold
      inverse_range = rule.threshold .. 4000
    elsif rule.op == :>
      range = (rule.threshold + 1) .. 4000
      inverse_range = 1 .. rule.threshold
    end
    cond = [rule.category, range]
    results_for_dest = paths(rule.destination, workflows_map)
    results_for_dest.each do |result_for_dest|
      res << (result_for_dest + inverted_conditions + [cond])
    end
    inverted_conditions << [rule.category, inverse_range]
  end

  results_for_fallback = paths(workflow.fallback, workflows_map)
  results_for_fallback.each do |result_for_fallback|
    res << result_for_fallback + inverted_conditions
  end

  res
end

all_paths = paths('in', workflows_map)
pt2 = all_paths.sum do |path|
  xs = path.filter_map {|char, range| range if char == 'x'}.map(&:to_a).reduce(&:&)&.size || 4000
  ms = path.filter_map {|char, range| range if char == 'm'}.map(&:to_a).reduce(&:&)&.size || 4000
  as = path.filter_map {|char, range| range if char == 'a'}.map(&:to_a).reduce(&:&)&.size || 4000
  ss = path.filter_map {|char, range| range if char == 's'}.map(&:to_a).reduce(&:&)&.size || 4000
  xs * ms * as * ss
end
puts "Part 2: #{pt2}"
