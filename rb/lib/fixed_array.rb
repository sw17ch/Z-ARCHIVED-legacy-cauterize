module Cauterize
  def fixed_array(name)
    a = fixed_arrays[name] || fixed_arrays[name] = FixedArray.new(name)
    yield a if block_given?
    return a
  end

  def fixed_array!(name, &blk)
    if fixed_arrays[name]
      raise Exception.new("FixedArray with name #{name} already exists.")
    else
      fixed_array(name, &blk)
    end
  end

  def fixed_arrays
    @fixed_ararys ||= {}
  end

  class FixedArray < BaseType
    def initialize(name)
      super
    end

    def array_type(t)
      @array_type = BaseType.find_type!(t)
    end

    def array_size(s)
      @array_size = s
    end
  end
end
