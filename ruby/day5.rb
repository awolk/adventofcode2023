require_relative './lib/aoc'

MapRange = Struct.new(:destination_start, :source_start, :length) do
  def source_end = source_start + length - 1
  
  def translate(number)
    if number.between?(source_start, source_end)
      destination_start + (number - source_start)
    end
  end
end

MapSet = Struct.new(:ranges) do
  def map_number(number)
    ranges.map {|range| range.translate(number)}.compact.first || number
  end

  def map_range(input_range)
    first, last = input_range.first, input_range.last

    ordered_ranges = ranges.sort_by(&:source_start)

    result = []
    just_before = first

    ordered_ranges.each do |range|
      break if just_before > last

      if just_before > range.source_end
        # we're past this range
        next
      end

      if just_before < range.source_start
        # catch up to range, there's no mapping
        catchup_until = [range.source_start - 1, last].min
        result << (just_before .. catchup_until)
        just_before = catchup_until + 1
      end
      break if just_before > last

      # use the mapping from range
      map_until = [range.source_end, last].min
      result << (range.translate(just_before) .. range.translate(map_until))
      just_before = map_until + 1
    end

    if just_before <= last
      result << (just_before .. last)
    end

    result
  end
end

# accepts an integer or an array of ranges
def through_mappings(mappings, thing)
  mappings.each do |mapping|
    case thing
    when Integer
      thing = mapping.map_number(thing)
    when Array
      thing = thing.flat_map {|range| mapping.map_range(range)}
    end
  end
  thing
end

input = AOC.get_input(5)
sections = input.split("\n\n")
seeds = sections[0][7..].split.map(&:to_i)

mappings = sections[1..].map do |section|
  ranges = section.split("\n")[1..].map do |line|
    MapRange.new(*line.split.map(&:to_i))
  end
  MapSet.new(ranges)
end

pt1 = seeds.map {|seed| through_mappings(mappings, seed)}.min
puts "Part 1: #{pt1}"

ranges = seeds.each_slice(2).map {|a, b| a..(a+b - 1)}
pt2 = through_mappings(mappings, ranges).map(&:first).min
puts "Part 2: #{pt2}"