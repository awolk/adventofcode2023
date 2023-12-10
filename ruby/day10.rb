require_relative './lib/aoc'

def valid_pos?(grid, (r, c))
  r.between?(0, grid.row_count - 1) && c.between?(0, grid.column_count - 1)
end

# returns a map of position to distance, calling blk to get neighbors
def bfs(grid, start, &blk)
  distances = {}
  dist = 0
  next_to_visit = Set[start]
  
  while !next_to_visit.empty?
    to_visit = next_to_visit
    next_to_visit = Set[]

    to_visit.each do |pos|
      r, c = pos
      next if !valid_pos?(grid, pos)
      next if distances.key?(pos) # skip if we've already visited

      distances[pos] = dist
      next_to_visit.merge(blk.call(pos))
    end
    dist += 1
  end

  distances
end

def all_neighbors((r, c))
  Set[[r+1, c], [r-1, c], [r, c+1], [r, c-1]]
end

def connected(grid, pos)
  r, c = pos
  case grid[r, c]
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
  when 'S'
    # find pipes that point at start
    all_neighbors(pos).select do |neighbor|
      connected(grid, neighbor).include?(pos)
    end
  else
    []
  end
end

input = AOC.get_input(10)
grid = AOC.char_matrix(input)
starting_pos = grid.index('S')

distances = bfs(grid, starting_pos) {|pos| connected(grid, pos)}
pt1 = distances.values.max
puts "Part 1: #{pt1}"

def enclosed_tiles(grid, start_pos, in_loop)
  return Set[] if in_loop.include?(start_pos)

  # use bfs to do a flood fill
  bfs(grid, start_pos) do |pos|
    (all_neighbors(pos).reject {in_loop.include?(_1)}).tap do |neighbors|
      raise "escaped" if neighbors.any? {|n| !valid_pos?(grid, n)}
    end
  end.keys.to_set
end

in_loop = distances.keys.to_set
# As we go through the loop "clockwise", anything on our right will be enclosed.
# There are two possible directions, find the one that doesn't result in an
# "escape" when traversing enclosed tiles.
pt2 = connected(grid, starting_pos).lazy.filter_map do |second_pos|
  all_enclosed_positions = Set[]

  came_from = starting_pos
  at = second_pos

  while at != starting_pos
    r, c = at
    next_pos = connected(grid, at).find {_1 != came_from}
    to_my_right =
      case [grid[r, c], came_from]
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
      end

    to_my_right.each do |pos|
      next if all_enclosed_positions.include?(pos)
      all_enclosed_positions.merge(enclosed_tiles(grid, pos, in_loop))
    end
  
    came_from = at
    at = next_pos
  end

  all_enclosed_positions.size
rescue
  nil # ignore the direction that escaped
end.first
puts "Part 2: #{pt2}"