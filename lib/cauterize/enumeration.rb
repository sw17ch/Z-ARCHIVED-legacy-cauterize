# enumeration.rb
#
# Enumerations correspond exactly to C enumerations.

require 'set'

module Cauterize
  module_function
  def enumeration(name, desc=nil)
    e = Cauterize.enumerations[name] || Cauterize.enumerations[name] = Enumeration.new(name, desc)
    yield e if block_given?
    return e
  end

  def enumeration!(name, desc=nil, &blk)
    if Cauterize.enumerations[name]
      raise Exception.new("Enumeration with name #{name} already exists.")
    else
      Cauterize.enumeration(name, desc, &blk)
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

    def value_hash(digest)
      digest.update(@name.to_s)
      digest.update(@value.to_s)
    end
  end

  class Enumeration < BaseType
    attr_reader :values

    def initialize(name, desc=nil)
      super
      @values = {}
      @value_id = 0
      @used_ids = Set.new
    end

    def value(name, id=nil)
      if @values[name]
        raise Exception.new("Cannot duplicate name #{name}.")
      end

      next_id = value_id(id)
      @used_ids << next_id
      @values[name] = EnumerationValue.new(name, next_id)
    end

    def representation
      Representation.enumRepresentation(
        min: @values.values.map(&:value).min,
        max: @values.values.map(&:value).max
      )
    end
    
    protected

    def local_hash(digest)
      representation.type_hash(digest)
      values.keys.sort.inject(digest) {|d, k|
        values[k].value_hash(digest)
      }
    end

    private

    def value_id(next_id=nil)
      if next_id
        @value_id = next_id.to_i
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
