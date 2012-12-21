# enumeration.rb
#
# Enumerations correspond exactly to C enumerations.

require 'set'

module Cauterize
  def enumeration(name)
    e = enumerations[name] || enumerations[name] = Enumeration.new(name)
    yield e if block_given?
    return e
  end

  def enumeration!(name, &blk)
    if enumerations[name]
      raise Exception.new("Enumeration with name #{name} already exists.")
    else
      enumeration(name, &blk)
    end
  end

  def enumerations
    @enumerations ||= {}
  end

  class EnumerationValue
    attr_reader :name, :value

    def initialize(name, value)
      @name = name
      @value = value
    end
  end

  class Enumeration < BaseType
    attr_reader :values

    def initialize(name)
      super
      @values = {}
      @value_id = 0
      @used_ids = Set.new
      @representation = BaseType.find_type!(:uint32_t)
    end

    def representation(type_name)
      @representation = BaseType.find_type!(type_name)
    end

    def value(name, id=nil)
      if @values[name]
        raise Exception.new("Cannot duplicate name #{name}.")
      end

      next_id = value_id(id)
      @used_ids << next_id
      @values[name] = EnumerationValue.new(name, next_id)
    end

    private

    def value_id(next_id=nil)
      if next_id
        @value_id = next_id
      end

      v = @value_id

      if @used_ids.include? v
        raise Exception.new("Cannot duplicate constant #{v}.")
      end

      loop do
        @value_id += 1
        break unless @used_ids.include? @value_id
      end

      return v
    end
  end
end
