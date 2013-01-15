# scalar.rb
#
# scalars are types that, in C, can be updated with assignment. This includes
# native types in C and typedefs around these native types.
#
# scalars are not structs, enumerations, unions, or arrays.

module Cauterize
  module_function

  def scalar(name)
    a = Cauterize.scalars[name] || Cauterize.scalars[name] = Scalar.new(name)
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
    def initialize(name)
      super
    end
  end
end
