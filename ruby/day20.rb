require_relative './lib/aoc'
require_relative './lib/grid'
require_relative './lib/parser'

name_p = P.str('broadcaster').map {['broadcaster', 'broadcaster']} | P.seq(P.regexp(/[%&]/), P.word)
mod_p = P.seq(name_p, ' -> ', P.word.delimited(', '))
parser = mod_p.each_line


input = AOC.get_input(20)
# input = AOC.get_example_input(20)
modules = parser.parse_all(input)

mod_inputs = modules.flat_map do |(type, name), destinations|
  destinations.map {[_1, name]}
end.group_by(&:first).transform_values {_1.map(&:last)}

flip_flop_states = modules.filter_map do |(type, name), destinations|
  [name, false] if type == '%'
end.to_h
conjunction_states = modules.filter_map do |(type, name), destinations|
  [name, mod_inputs[name].map {[_1, false]}.to_h] if type == '&'
end.to_h

mods_by_name = modules.map do |(type, name), destinations|
  [name, [type, destinations]]
end.to_h

pulses = {false => 0, true => 0}
1000.times do
  to_send = [['button', false, 'broadcaster']]

  while !to_send.empty?
    source, pulse_type, dest = to_send.shift
    # puts "#{source} -#{pulse_type ? 'high' : 'low'}-> #{dest}"
    pulses[pulse_type] += 1

    dest_type, dest_dests = mods_by_name[dest]
    case dest_type
    when 'broadcaster'
      to_send.concat(dest_dests.map {[dest, pulse_type, _1]})
    when '%'
      if !pulse_type
        flip_flop_states[dest] = !flip_flop_states[dest]
        to_send.concat(dest_dests.map {[dest, flip_flop_states[dest], _1]})
      end
    when '&'
      conjunction_states[dest][source] = pulse_type
      new_pulse_type = !conjunction_states[dest].values.all?
      to_send.concat(dest_dests.map {[dest, new_pulse_type, _1]})
    end
  end
end

pt1 = pulses[false] * pulses[true]
puts "Part 1: #{pt1}"

pt2 = 0
puts "Part 2: #{pt2}"
