# composite.rb
#
# Composites correspond to C structs.

module Cauterize
  module_function

  def composite(name, desc=nil)
    c = Cauterize.composites[name] || Cauterize.composites[name] = Composite.new(name, desc)
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
    attr_reader :name, :type, :description
    def initialize(field_name, type_name, desc=nil)
      @name = field_name
      @type = BaseType.find_type!(type_name)
      @description = desc
    end
  end

  class Composite < BaseType
    attr_reader :fields

    def initialize(name, desc=nil)
      super
      @fields = {}
    end

    def field(name, type, desc=nil)
      if @fields[name]
        raise Exception.new("Field name #{name} already used.")
      else
        @fields[name] = CompositeField.new(name, type, desc)
      end
    end
  end
end
