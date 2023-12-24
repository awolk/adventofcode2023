# A small parser combinator library
module P
  class ParserError < StandardError; end

  class Parser
    def initialize(&blk)
      @blk = blk
    end

    def parse(input)
      @blk.call(input)
    end

    def map(&blk)
      Parser.new do |input|
        res, rest = @blk.call(input)
        [blk.call(res), rest]
      end
    end

    # Parse self or other
    def |(other)
      Parser.new do |input|
        parse(input)
      rescue ParserError
        other.parse(input)
      end
    end

    # Parse self then other, returning both results
    def &(other)
      P.seq(self, other)
    end

    # Parse self then other, dropping result from self
    def >>(other)
      (self & other).map(&:last)
    end

    # Parse self then other, dropping result from other
    def <<(other)
      (self & other).map(&:first)
    end

    # Parse self repeated 0 or more times
    def repeated
      Parser.new do |input|
        results = []
        rest = input
        loop do
          res, rest = parse(rest)
          results << res
        rescue ParserError
          break
        end
        [results, rest]
      end
    end

    # Parse self or nothing
    def optional
      Parser.new do |input|
        parse(input)
      rescue ParserError
        [nil, input]
      end
    end

    # Parse self delimited by delimiter
    def delimited(delimiter)
      delimiter = P.str(delimiter) if delimiter.is_a?(String)
      delimiter = P.regexp(delimiter) if delimiter.is_a?(Regexp)
      (self & (delimiter >> self).repeated)
        .map { |hd, tl| [hd] + tl } |
        P.nothing([])
    end

    # Parse self on each line of input
    def each_line
      delimited(P.str("\n"))
    end

    def parse_all(input)
      res, rest = parse(input)
      raise ParserError, 'Expected complete parsing' unless rest.empty?

      res
    end
  end

  ## Base parsers

  def self.nothing(res=nil)
    Parser.new do |input|
      [res, input]
    end
  end

  def self.str(s)
    Parser.new do |input|
      raise ParserError, "Expected '#{s}'" unless input.start_with?(s)

      [s, input[s.length..]]
    end
  end

  def self.regexp(r)
    r = /\A#{r}/
    Parser.new do |input|
      raise ParserError, "Expected regular expression /#{r}/" unless (m = r.match(input))

      [m[0], m.post_match]
    end
  end

  def self.int
    regexp(/-?\d+/).map(&:to_i)
  end

  def self.word
    regexp(/\w+/)
  end

  def self.whitespace
    regexp(/\s+/).map {nil}
  end

  # Sequence of parsers in order. Drops raw string results
  def self.seq(*parsers)
    Parser.new do |i|
      results = []
      rest = i
      parsers.each do |p|
        if p.is_a?(String)
          _, rest = str(p).parse(rest)
        else
          p = P.regexp(p) if p.is_a?(Regexp)
          res, rest = p.parse(rest)
          results << res
        end
      end
      [results, rest]
    end
  end

  def self.any(parsers)
    parsers.map do |parser|
      if parser.is_a?(String)
        P.str(parser)
      else
        parser
      end
    end.reduce(&:|)
  end

  def self.lazy(&blk)
    Parser.new do |i|
      blk.call.parse(i)
    end
  end

  def self.recursive(&blk)
    res = P.lazy do
      res.instance_eval(&blk)
    end
  end
end