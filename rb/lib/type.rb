class Type
  def self.parse(str)
    m = str.match(/(?<base>[^\[]+)(?:\[(?<array>[^\]]+)\])?/)
    hash = Hash[ m.names.zip( m.captures ) ]
    validate(hash, "base", "array")
    array = hash["array"] ? hash["array"] : nil
    Type.new(hash["base"], array)
  end

  def initialize(type, array_size=nil)
    @type = type
    @size = array_size
  end

  def type_str
    @type
  end

  def array_str
    if @size
      "[#{@size}]"
    else
      ""
    end
  end
end

