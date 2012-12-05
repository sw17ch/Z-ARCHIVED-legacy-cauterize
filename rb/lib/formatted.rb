class Formatted
  def initialize(name)
    @name = name
    @enums = []
    @structs = []
    @functions = []
  end

  def enum
    raise :unimplemented
  end

  def struct(name, fields=[])
    @structs << CStruct.new(name, fields)
    return self
  end

  def packer(name, fields)
    function(name, "CAUTERIZE_STATUS_T", fields)
  end

  def unpacker(name, fields)
  end

  def h_file
    header = Formatter.new
    header << "#ifndef #{@name.up_snake}_H"
    header << "#define #{@name.up_snake}_H"
    @enums.each {|e| e.definition(header)}
    @structs.each {|s| s.prototype(header)}
    @functions.each {|f| f.prototype(header)}
    header << "#endif /* #{@name.up_snake}_H */"
    header.blank_line
    header.to_s
  end

  def c_file
    raise :unimplemented
  end

  def cs_file
    raise :unimplemented
  end

  private

  def function(name, ret, params)
    @functions << CFunction.new(name, ret, params)
  end
end
