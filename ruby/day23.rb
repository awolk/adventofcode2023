require_relative './lib/aoc'
require_relative './lib/grid'
require_relative './lib/parser'

def max_path(start, goal, visited=Set[], &blk)
  # DFS
  to_visit = [[start, 0, Set[]]]
  max_dist = -1
  while !to_visit.empty?
    at, dist, visited = to_visit.pop
    max_dist = dist if at == goal && dist > max_dist

    new_visited = visited + [at]
    blk.call(at).each do |neighbor, n_dist|
      next if visited.include?(neighbor)
      to_visit << [neighbor, dist + n_dist, new_visited]
    end
  end
  max_dist
end

input = AOC.get_input(23)
grid = Grid.chars(input)

start = [0, grid.row(0).index('.')]
goal = [grid.row_count - 1, grid.row(-1).index('.')]

pt1 = max_path(start, goal) do |pos|
  r, c = pos
  val = grid[pos]
  case val
  when '#'
    []
  when '<'
    [[[r, c - 1], 1]]
  when '>'
    [[[r, c + 1], 1]]
  when '^'
    [[[r - 1, c], 1]]
  when 'v'
    [[[r + 1, c], 1]]
  when '.'
    grid.neighbor_positions(pos, diagonals: false).map do |pos|
      [pos, 1]
    end
  end
end
puts "Part 1: #{pt1}"

# Find "nodes", positions where a choice can be made, and the distances between
# them, and use this simplified graph to find the max path length.
node_dists = {}
nodes = Set[start, goal]
grid.each_with_index do |val, r, c|
  pos = [r, c]
  next if val == '#'
  count_paths = grid.neighbors(pos, diagonals: false).count do |nval, _|
    nval != '#'
  end
  nodes << pos if count_paths > 2
end

nodes.each do |node_pos|
  # bfs from nodes to find reachable nodes and distances
  visited = Set[]
  to_visit = [[node_pos, 0]]
  while !to_visit.empty?
    visiting, dist = to_visit.shift
    visited.add(visiting)
    if visiting != node_pos && nodes.include?(visiting)
      (node_dists[node_pos] ||= {})[visiting] = dist
      (node_dists[visiting] ||= {})[node_pos] = dist
    else
      neighbors = grid.neighbors_with_positions(visiting, diagonals: false).filter_map do |val, npos|
        npos if val != '#'
      end.to_set - visited
      to_visit.concat(neighbors.map {|npos| [npos, dist + 1]})
    end
  end
end

pt2 = max_path(start, goal, &node_dists)
puts "Part 2: #{pt2}"
