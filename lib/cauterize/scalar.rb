# scalar.rb
#
# scalars are types that, in C, can be updated with assignment. This includes
# native types in C and typedefs around these native types.
#
# scalars are not structs, enumerations, unions, or arrays.

module Cauterize
  module_function

  def scalar(name, desc=nil)
    a = Cauterize.scalars[name] || Cauterize.scalars[name] = Scalar.new(name, desc)
    yield a if block_given?
    return a
  end

  def scalar!(name, &blk)
    if Cauterize.scalars[name]
      raise Exception.new("Scalar with name #{name} already exists.")
    else
      Cauterize.scalar(name, &blk)
    end
  end

  def scalars
    @scalars ||= {}
  end

  class Scalar < BaseType
    def initialize(name, desc=nil)
      super
    end

    def type_name(type_name = nil)
      if type_name
        t = BaseType.find_type!(type_name)
        if t.class != BuiltIn
          raise Exception.new("Must specify a BuiltIn type for scalars.")
        end

        @type_name = t
      else
        @type_name
      end
    end
  end
end
