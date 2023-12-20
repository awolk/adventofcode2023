require_relative './lib/aoc'
require_relative './lib/parser'

Mod = Struct.new(:name, :type, :destinations)

class ModSet
  def initialize(modules)
    @modules = modules
    @mods_by_name = modules.map {[_1.name, _1]}.to_h
    @inputs = modules.flat_map(&:destinations).uniq.map do |name|
      [name, modules.select {_1.destinations.include?(name)}.map(&:name)]
    end.to_h
  end

  def inputs(name) = @inputs[name]
  def mod(name) = @mods_by_name[name]
  def mods_of_type(type) = @modules.filter {|mod| mod.type == type}
end

class Simulation
  def initialize(mod_set)
    @mod_set = mod_set
    @flip_flop_states = mod_set.mods_of_type('%').map do |mod|
      [mod.name, false]
    end.to_h
    @conjunction_states = mod_set.mods_of_type('&').map do |mod|
      [mod.name, mod_set.inputs(mod.name).map {[_1, false]}.to_h]
    end.to_h
    @pulses = {false => 0, true => 0}
  end

  # returns true if met awaiting condition
  def button_press!(awaiting_high_output: nil)
    to_send = [['button', false, 'broadcaster']]

    while !to_send.empty?
      source, pulse_type, dest = to_send.shift
      # puts "#{source} -#{pulse_type ? 'high' : 'low'}-> #{dest}"
      @pulses[pulse_type] += 1

      return true if awaiting_high_output == source && pulse_type

      mod = @mod_set.mod(dest)
      next if mod.nil?

      case mod.type
      when 'broadcaster'
        to_send.concat(mod.destinations.map {[dest, pulse_type, _1]})
      when '%'
        if !pulse_type
          @flip_flop_states[dest] = !@flip_flop_states[dest]
          to_send.concat(mod.destinations.map {[dest, @flip_flop_states[dest], _1]})
        end
      when '&'
        @conjunction_states[dest][source] = pulse_type
        new_pulse_type = !@conjunction_states[dest].values.all?
        to_send.concat(mod.destinations.map {[dest, new_pulse_type, _1]})
      end
    end
    false
  end

  def pt1_score = @pulses[false] * @pulses[true]
end

name_p = P.str('broadcaster').map {[_1, _1]} | P.seq(P.regexp(/[%&]/), P.word)
mod_p = P.seq(name_p, ' -> ', P.word.delimited(', ')).map {|(type, name), dests| Mod.new(name, type, dests)}
parser = mod_p.each_line.map {ModSet.new(_1)}

input = AOC.get_input(20)
mod_set = parser.parse_all(input)

pt1_sim = Simulation.new(mod_set)
1000.times {pt1_sim.button_press!}
pt1 = pt1_sim.pt1_score
puts "Part 1: #{pt1}"

raise unless mod_set.inputs('rx').length == 1
rx_input = mod_set.inputs('rx').first
raise unless mod_set.mod(rx_input).type == '&'
# We have a single conjunction as input to rx, so we want to find the cycle that
# each of the inputs to the conjugation emit a high pulse, and take the LCM.
pt2 = mod_set.inputs(rx_input).map do |looking_for_high_cycle|
  sim = Simulation.new(mod_set)
  (1..).find {sim.button_press!(awaiting_high_output: looking_for_high_cycle)}
end.reduce(:lcm)
puts "Part 2: #{pt2}"
