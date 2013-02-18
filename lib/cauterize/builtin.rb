module Cauterize
  module_function

  BUILT_IN_TYPES = [
    { :name => :int8,   :size => 1, :signed => true },
    { :name => :int16,  :size => 2, :signed => true },
    { :name => :int32,  :size => 4, :signed => true },
    { :name => :int64,  :size => 8, :signed => true },
    { :name => :uint8,  :size => 1, :signed => false },
    { :name => :uint16, :size => 2, :signed => false },
    { :name => :uint32, :size => 4, :signed => false },
    { :name => :uint64, :size => 8, :signed => false },
  ]

  def builtins
    @builtins ||= {}
  end

  def create_builtins
    BUILT_IN_TYPES.each do |b|
      _b = BuiltIn.new(b[:name])
      _b.byte_length(b[:size])
      _b.is_signed(b[:signed])
      builtins[b[:name]] = _b
    end
  end

  class BuiltIn < BaseType
    def initialize(name)
      super
    end

    def is_signed(signed = nil)
      unless signed.nil?
        @is_signed = signed
      else
        @is_signed
      end
    end

    def byte_length(len = nil)
      unless len.nil?
        @byte_length = len
      else
        @byte_length
      end
    end
  end

  # Create all the builtin types.
  create_builtins
end
