class Formatter
  def initialize
    @indent_level = 0
    @indent_str = "  "
    @lines = []
  end

  def indent(line)
    (@indent_str * @indent_level) + line
  end

  def <<(line)
    @lines << indent(line)
  end

  def append(text)
    if @lines.length == 0
      @lines << ""
    end

    @lines[-1] += text
  end

  def braces
    self << "{"
    indented { yield self } if block_given?
    self << "}"
  end

  def to_s(extra_indent = 0)
    @indent_level += extra_indent
    s = @lines.map {|l| indent(l) }.join("\n")
    @indent_level -= extra_indent
    return s
  end

  private

  def indented
    @indent_level += 1
    yield self
    @indent_level -= 1
  end
end
