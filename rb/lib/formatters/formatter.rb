class Formatter
  attr_accessor :indent_str

  def initialize
    @indent_level = 0
    @indent_str = "  "
    @lines = []
  end

  def indent(line)
    (@indent_str * @indent_level) + line
  end

  def braces
    self << "{"
    if block_given?
      yield self
    end
    self << "{"
  end

  def <<(line)
    @lines << indent(line)
  end

  def append(text)
    if @lines.length == 0
      @lines << ""
    end

    @lines.last += text
  end

  def to_s(indent_level)
    @indent_level += indent_level
    lines.map {|l| indent(l) }
    @indent_level -= indent_level
  end
end
