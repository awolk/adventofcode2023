require 'tempfile'
require 'open3'
require_relative './lib/aoc'
require_relative './lib/parser'

Stone = Struct.new(:pos, :vel) do
  def intersection(other)
    return nil if slope == other.slope

    x = (other.intercept - intercept) / (slope - other.slope)
    y = slope * x + intercept
    t = (x - pos[0]) / vel[0]
    ot = (x - other.pos[0]) / other.vel[0]
    [x, y, t, ot]
  end

  def intercept = pos[1] - pos[0] * slope
  def slope = vel[1] / vel[0]
end

vec_p = P.int.map(&:to_f).delimited(/,\s*/).map {Vector[*_1]}
stone_p = P.seq(vec_p, /\s*@\s*/, vec_p).map {|pos, _, vel| Stone.new(pos, vel)}
stones_p = stone_p.each_line

input = AOC.get_input(24)
stones = stones_p.parse_all(input)

range = 200000000000000 .. 400000000000000
pt1 = stones.combination(2).count do |stone_a, stone_b|
  intersection = stone_a.intersection(stone_b)
  next false if intersection.nil?

  x, y, t, ot = intersection
  next false if t < 0 || ot < 0

  range.include?(x) && range.include?(y)
end
puts "Part 1: #{pt1}"

# Use Z3 to solve part 2
z3_in = Tempfile.new
z3_in.write <<~Z3
  (declare-const sx Int)
  (declare-const sy Int)
  (declare-const sz Int)
  (declare-const svx Int)
  (declare-const svy Int)
  (declare-const svz Int)
Z3
stones.each_with_index do |stone, i|
  z3_in.write <<~Z3
    (declare-const t#{i} Int)
    (assert (= (+ sx (* t#{i} svx)) (+ #{stone.pos[0].to_i} (* #{stone.vel[0].to_i} t#{i}))))
    (assert (= (+ sy (* t#{i} svy)) (+ #{stone.pos[1].to_i} (* #{stone.vel[1].to_i} t#{i}))))
    (assert (= (+ sz (* t#{i} svz)) (+ #{stone.pos[2].to_i} (* #{stone.vel[2].to_i} t#{i}))))
  Z3
end
z3_in.write <<~Z3
  (check-sat)
  (eval (+ sx sy sz))
Z3

z3_in.close
output = `z3 #{z3_in.path}`
z3_in.unlink

raise "invalid output" unless /sat\n(?<pt2>\d+)/ =~ output
puts "Part 2: #{pt2}"