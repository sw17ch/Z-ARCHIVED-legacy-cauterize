module Cauterize
  module_function

  def variable_array(name)
    a = variable_arrays[name] || variable_arrays[name] = VariableArray.new(name)
    yield a if block_given?
    return a
  end

  def variable_array!(name, &blk)
    if variable_arrays[name]
      raise Exception.new("VariableArray with name #{name} already exists.")
    else
      variable_array(name, &blk)
    end
  end

  def variable_arrays
    @variable_ararys ||= {}
  end

  class VariableArray < BaseType
    def intialize(name)
      super
    end

    def array_type(t = nil)
      if t
        @array_type = BaseType.find_type!(t)
      else
        @array_type
      end
    end

    def array_size(s = nil)
      if s
        @array_size = s
      else
        @array_size
      end
    end

    def size_type(t = nil)
      if t
        _t = BaseType.find_type!(t)
        if _t.is_scalar?
          @size_type = _t
        else
          raise Exception.new("The type #{t} is not an scalar")
        end
      else
        @size_type
      end
    end
  end
end
