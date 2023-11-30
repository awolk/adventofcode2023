require 'matrix'
# Helper methods for Advent of Code solutions
module AOC
  def self.get_input(day)
    File.read(File.expand_path("../../input/day#{day}.txt", __dir__))
  end

  def self.get_example_input(day)
    File.read(File.expand_path("../../input/day#{day}example.txt", __dir__))
  end

  def self.digit_matrix(input)
    Matrix.rows(input.split("\n").map { _1.chars.map(&:to_i) })
  end

  def self.char_matrix(input)
    Matrix.rows(input.split("\n").map(&:chars))
  end

  def self.report_progress(x, total, every_perc)
    every = total * every_perc / 100
    if x % every == 0
      puts "#{(x * 100.0 / total).round}%"
    end
  end
end
