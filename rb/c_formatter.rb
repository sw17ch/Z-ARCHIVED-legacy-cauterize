require 'mixins'

class CFormatter
  def initialize(c_name, indent="  ")
    @c_name = c_name
    @indent = indent
    @level = 0
    @lines = []
    @func_prototypes = []
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

  def func(name, ret, params, &blk)
    braces("#{ret} #{name}(#{params.join(", ")})", &blk)
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

  def undented
    deindent
    yield self
    indent
  end

  def c_text
    @lines.join("\n")
  end

  def h_text
    gaurd = @c_name.up_snake + "_H"
    self << "#ifndef #{gaurd}"
    self << "#define #{gaurd}"

    self << "#endif /* #{gaurd} */"
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
