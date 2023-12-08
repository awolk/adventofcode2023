require_relative './lib/aoc'

input = AOC.get_input(8)

instr_s, network_s = input.split("\n\n")
instrs = instr_s.chars
network = network_s.split("\n").map do |line|
  node, l, r = line.scan(/[A-Z]{3}/)
  [node, {'L' => l, 'R' => r}]
end.to_h

def cycle_length(instrs, network, start, &blk)
  steps = 0
  pos = start
  while !blk.call(pos)
    instr = instrs[steps % instrs.length]
    steps += 1
    pos = network[pos][instr]
  end
  steps
end

pt1 = cycle_length(instrs, network, 'AAA') {_1 == 'ZZZ'}
puts "Part 1: #{pt1}"

starts = network.keys.select {_1.end_with?('A')}
cycles = starts.map do |start|
  cycle_length(instrs, network, start) {_1.end_with?('Z')}
end
lcm = cycles.reduce(1, :lcm)
puts "Part 2: #{lcm}"