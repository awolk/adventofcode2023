require_relative './lib/aoc'

def ways_to_beat_record(time, record_distance)
  (0..time).count do |time_held|
    distance = (time - time_held) * time_held
    distance > record_distance
  end
end

input = AOC.get_input(6)
lines = input.split("\n")

times = lines[0].split[1..].map(&:to_i)
distances = lines[1].split[1..].map(&:to_i)
races = times.zip(distances)

pt1 = races.map {ways_to_beat_record(_1, _2)}.reduce(:*)
puts "Part 1: #{pt1}"

time = lines[0].split(":")[1].gsub(" ", "").to_i
distance = lines[1].split(":")[1].gsub(" ", "").to_i
pt2 = ways_to_beat_record(time, distance)
puts "Part 2: #{pt2}"