require 'matrix'

class Grid
  def initialize(rows)
    @rows = rows
    @row_count = rows.length
    @column_count = rows[0].length
  end

  def self.chars(input)
    new(input.split("\n").map(&:chars))
  end

  def self.digits(input)
    new(input.split("\n").map {|line| line.chars.map(&:to_i)})
  end

  attr_reader :rows, :row_count, :column_count

  def [](r, c=nil)
    r, c = r if r.is_a?(Array)
    @rows[r]&.[](c)
  end

  def []=(*args)
    if args.length == 2
      (r, c), val = args
    elsif args.length == 3
      r, c, val = args
    else
      raise 'invalid arguments'
    end
    @rows[r][c] = val
  end

  def row(r)
    @rows[r]
  end
  
  def column(c)
    @rows.map {|row| row[c]}
  end

  def columns
    @rows.transpose
  end

  def valid_pos?(r, c=nil)
    r, c = r if r.is_a?(Array)
    r.between?(0, @row_count - 1) && c.between?(0, @column_count - 1)
  end

  def at_edge?(r, c=nil)
    r, c = r if r.is_a?(Array)
    r == 0 || r == @row_count - 1 || c == 0 || c == @column_count - 1
  end

  def clone
    Grid.new(@rows.map(&:clone))
  end

  def transpose
    Grid.new(@rows.transpose)
  end

  def each_with_index(&blk)
    return to_enum(:each_with_index) if blk.nil?
    @rows.each_with_index do |row, row_index|
      row.each_with_index do |val, col_index|
        blk.call(val, row_index, col_index)
      end
    end
  end

  def index(target)
    each_with_index do |val, r, c|
      return [r, c] if val == target
    end
    nil
  end

  def all_indexes(target)
    each_with_index.filter_map do |val, r, c|
      [r, c] if val == target
    end
  end

  def neighbor_positions(r, c=nil, diagonals: true)
    r, c = r if r.is_a?(Array)
    if diagonals
      [r-1, r, r+1].product([c-1, c, c+1])
    else
      [[r, c-1], [r, c+1], [r-1, c], [r+1, c]]
    end.select do |pos|
      pos != [r, c] && valid_pos?(pos)
    end
  end

  def neighbors_with_positions(r, c=nil, diagonals: true)
    neighbor_positions(r, c, diagonals: diagonals).map do |pos|
      [self[pos], pos]
    end
  end

  def neighbors(r, c=nil, diagonals: true)
    neighbor_positions(r, c, diagonals: diagonals).map do |pos|
      self[pos]
    end
  end

  def row_strings
    @rows.map(&:join)
  end
end