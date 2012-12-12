class Field
  attr_accessor :type, :count

  def initialize(name, type_sym)
    @name = name
    @type = find_type!(type_sym)
    @count = nil
  end

  def declare(formatter)
    @type.declare(formatter, @name, @count)
  end
end

