require_relative './lib/aoc'

def arrangements(line, groups)
  # res[[x, y]] = arrangements(line[x..], groups[y..])
  res = {}
  
  ## fill in cases where line or groups is empty
  # if both are empty, valid
  res[[line.length, groups.length]] = 1
  # if line is empty but groups is not, not valid
  (0...groups.length).each do |nonempty_group_length|
    res[[line.length, nonempty_group_length]] = 0
  end

  line_can_have_no_groups_after = line.rindex('#') || 0
  # if groups are empty but line still has a #, invalid
  (0 .. line_can_have_no_groups_after).each do |rest_of_line_not_empty|
    res[[rest_of_line_not_empty, groups.length]] = 0
  end
  # if groups are empty and line has no more #, valid
  ((line_can_have_no_groups_after + 1) .. (line.length + 1)).each do |possible_empty_rest_of_line|
    res[[possible_empty_rest_of_line, groups.length]] = 1
  end

  ## fill in rest of result matrix
  (0 ... line.length).to_a.product((0 ... groups.length).to_a).reverse.each do |line_index, group_index|
    remaining_line = line[line_index..]
    remaining_groups = groups[group_index..]

    if remaining_line.start_with?('#') || remaining_line.start_with?('?')
      if remaining_line.length < remaining_groups.first
        # not enough to satisfy the first group
        res[[line_index, group_index]] = 0
        next
      end
        
      if !remaining_line[...remaining_groups.first].include?('.') && remaining_line[remaining_groups.first] != '#'
        # we've got an exact match for the start of the line
        # the character after the group can't be '#', so skip that too
        next_line_index = [line_index + remaining_groups.first + 1, line.length].min
        res[[line_index, group_index]] = res[[next_line_index, group_index + 1]]
      else
        # no match
        res[[line_index, group_index]] = 0
      end

      if remaining_line.start_with?('?')
        # also treat the ? as a .
        res[[line_index, group_index]] += res[[line_index + 1, group_index]]
      end
    elsif remaining_line.start_with?('.')
      # skip the dots
      skip = remaining_line.chars.index {_1 != '.'} || remaining_line.length
      res[[line_index, group_index]] = res[[line_index + skip, group_index]]
    end
  end

  res[[0, 0]]
end

input = AOC.get_input(12).split("\n").map do |line|
  row, ints_s = line.split
  [row, ints_s.split(',').map(&:to_i)]
end

pt1 = input.sum {arrangements(_1, _2)}
puts "Part 1: #{pt1}"

pt2_input = input.map do |row, ints|
  [Array.new(5, row).join('?'), ints * 5]
end
pt2 = pt2_input.sum {arrangements(_1, _2)}
puts "Part 2: #{pt2}"