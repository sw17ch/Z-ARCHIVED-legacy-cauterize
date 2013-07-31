module Cauterize
  module_function

  BUILT_IN_TYPES = [
    { :name => :int8,    :size => 1, :flavor => :signed },
    { :name => :int16,   :size => 2, :flavor => :signed },
    { :name => :int32,   :size => 4, :flavor => :signed },
    { :name => :int64,   :size => 8, :flavor => :signed },
    { :name => :uint8,   :size => 1, :flavor => :unsigned },
    { :name => :uint16,  :size => 2, :flavor => :unsigned },
    { :name => :uint32,  :size => 4, :flavor => :unsigned },
    { :name => :uint64,  :size => 8, :flavor => :unsigned },
    { :name => :float32, :size => 4, :flavor => :float },
    { :name => :float64, :size => 8, :flavor => :float },
    { :name => :bool,    :size => 1, :flavor => :bool },
  ]

  def builtins
    @builtins ||= {}
  end

  def create_builtins
    BUILT_IN_TYPES.each do |b|
      _b = BuiltIn.new(b[:name], nil)
      _b.byte_length(b[:size])
      _b.flavor(b[:flavor])
      builtins[b[:name]] = _b
    end
  end

  class BuiltIn < BaseType
    def initialize(name, desc=nil)
      super
    end

    def flavor(f = nil)
      unless f.nil?
        @flavor = f
      else
        @flavor
      end
    end

    def byte_length(len = nil)
      unless len.nil?
        @byte_length = len
      else
        @byte_length
      end
    end

    protected

    def local_hash(digest)
      digest.update(@flavor.to_s)
      digest.update(@byte_length.to_s)
    end
  end

  # Create all the builtin types.
  create_builtins
end
