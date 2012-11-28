class CFormatter
  def initialize(indent="  ")
    @indent = indent
    @level = 0
    @lines = []
  end

  def blank_line
    @lines << ""
  end

  def <<(line)
    @lines << indent_line(line.strip)
  end

  def append_last(str)
    @lines.last and @lines.last.concat str
  end

  def struct(name)
    @lines << "struct #{name} {"
    indent
    yield self
    deindent
    @lines << "};"
  end

  def to_s
    @lines.join("\n")
  end

  private

  def indent
    @level += 1
  end

  def deindent
    @level -= 1
  end

  def indent_line(line)
    (@indent * @level) + line
  end
end
