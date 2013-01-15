# composite.rb
#
# Composites correspond to C structs.

module Cauterize
  module_function

  def composite(name)
    c = Cauterize.composites[name] || Cauterize.composites[name] = Composite.new(name)
    yield c if block_given?
    return c
  end

  def composite!(name, &blk)
    if Cauterize.composites[name]
      raise Exception.new("Composite with name #{name} already exists.")
    else
      Cauterize.composite(name, &blk)
    end
  end

  def composites
    @composites ||= {}
  end

  class CompositeField
    attr_reader :name, :type
    def initialize(field_name, type_name)
      @name = field_name
      @type = BaseType.find_type!(type_name)
    end
  end

  class Composite < BaseType
    attr_reader :fields

    def initialize(name)
      super
      @fields = {}
    end

    def field(name, type)
      if @fields[name]
        raise Exception.new("Field name #{name} already used.")
      else
        @fields[name] = CompositeField.new(name, type)
      end
    end
  end
end
