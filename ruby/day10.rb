require_relative './lib/aoc'

def neighbors(pos)
  r, c = pos
  [[r+1, c], [r-1, c], [r, c+1], [r, c-1]]
end

def connected(val, r, c)
  case val
  when '|'
    [[r+1, c], [r-1, c]]
  when '-'
    [[r, c+1], [r, c-1]]
  when 'L'
    [[r-1, c], [r, c+1]]
  when 'J'
    [[r-1, c], [r, c-1]]
  when '7'
    [[r, c-1], [r+1, c]]
  when 'F'
    [[r, c+1], [r+1, c]]
  else
    []
  end
end

input = AOC.get_input(10)
# input = AOC.get_example_input(10)

grid = AOC.char_matrix(input)

starting_pos = grid.index('S')
distances = {starting_pos => 0}

dist = 0
to_visit = []
r, c = starting_pos
# cheat: we know the loop connects through north and east from looking
# at the input
next_to_visit = [[r-1, c], [r, c+1]]

while !next_to_visit.empty?
  to_visit = next_to_visit
  next_to_visit = []
  dist += 1
  while !to_visit.empty?
    r, c = to_visit.pop
    next if r < 0 || c < 0
    next if distances.key?([r, c])
    val = grid[r, c]
    next if val.nil?
  
    distances[[r, c]] = dist
    connected_pos = connected(val, r, c)
    next_to_visit.concat(connected_pos)
  end
end

pt1 = distances.values.max
puts "Part 1: #{pt1}"

# as we go through the loop "clockwise", anything on our right will be enclosed,
# vs. on our left will be open

def connected_dots(grid, pos, in_loop)
  r, c = pos
  return Set[] if r < 0 || c < 0

  return Set[] if grid[r, c].nil? || in_loop.include?([r, c])


  res = Set[pos]
  to_visit = neighbors(pos)
  while !to_visit.empty?
    pos = to_visit.shift
    next if res.include?(pos)
    next if in_loop.include?(pos)
    r, c = pos
    raise "got out" if r < 0 || c < 0 || r >= grid.row_count || c >= grid.column_count
    next if r < 0 || c < 0
    val = grid[r, c]
    next if val.nil?

    res.add(pos)
    to_visit.concat(neighbors(pos))
  end
  
  res
end

enclosed_positions = Set[]
start = grid.index('S')
r, c = start
come_from = start
# cheat: start going up (tried going right, it errors)
at = [r-1, c]

in_loop = distances.keys.to_set

while at != start
  r, c = at
  val = grid[r, c]
  all_connected = connected(val, r, c)
  all_connected.delete(come_from)
  next_pos = all_connected.first


  to_my_right =
    case [val, come_from]
    when ['|', [r-1, c]] # came from top
      [[r, c-1]]
    when ['|', [r+1, c]] # came from bottom
      [[r, c+1]]

    when ['-', [r, c-1]] # came from left
      [[r+1, c]]
    when ['-', [r, c+1]] # came from right
      [[r-1, c]]

    when ['L', [r-1, c]] # came from top
      [[r, c-1], [r+1, c]]
    when ['L', [r, c+1]] # came from right
      []

    when ['J', [r-1, c]] # came from top
      []
    when ['J', [r, c-1]] # came from left
      [[r+1, c], [r, c+1]]

    when ['7', [r, c-1]] # came from left
      []
    when ['7', [r+1, c]] # came from bottom
      [[r, c+1], [r-1, c]]

    when ['F', [r, c+1]] # came from right
      [[r-1, c], [r, c-1]]
    when ['F', [r+1, c]] # came from bottom
      []

    else
      raise "uh oh"
    end
  
  to_my_right.each do |pos|
    enclosed_positions += connected_dots(grid, pos, in_loop)
  end

  come_from = at
  at = next_pos
end

pt2 = enclosed_positions.size
puts "Part 2: #{pt2}"