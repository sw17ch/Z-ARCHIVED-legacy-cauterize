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

  def struct(name, &blk)
    braces("struct #{name}", &blk)
    append_last(";")
  end

  def enum(name, &blk)
    braces("enum #{name}", &blk)
    append_last(";")
  end

  def braces(prefix="")
    @lines << indent_line("#{prefix} {")
    indent
    yield self
    deindent
    @lines << indent_line("}")
  end

  def append_last(str)
    @lines.last and @lines.last.concat str
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
