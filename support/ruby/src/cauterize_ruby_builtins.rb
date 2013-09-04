require_relative './cauterize_ruby_baseclasses'

class UInt8 < CauterizeBuiltinInteger
  def in_range(v) v >= 0 && v < 2**8 end
  def self.max_size() 1 end
  def cmp(other) to_ruby <=> other.to_ruby end
  def packio(x)
    x << [to_i].pack("C")
  end
  def self.unpackio(str)
    UInt8.new str.read(max_size).unpack("C")[0]
  end
end

class UInt16 < CauterizeBuiltinInteger
  def in_range(v) v >= 0 && v < 2**16 end
  def self.max_size() 2 end
  def cmp(other) to_ruby <=> other.to_ruby end
  def packio(x)
    x << [to_i].pack("S")
  end
  def self.unpackio(str)
    UInt16.new str.read(max_size).unpack("S")[0]
  end
end

class UInt32 < CauterizeBuiltinInteger
  def in_range(v) v >= 0 && v < 2**32 end
  def self.max_size() 4 end
  def cmp(other) to_ruby <=> other.to_ruby end
  def packio(x)
    x << [to_i].pack("L")
  end
  def self.unpackio(str)
    UInt32.new str.read(max_size).unpack("L")[0]
  end
end

class UInt64 < CauterizeBuiltinInteger
  def in_range(v) v >= 0 && v < 2**64 end
  def self.max_size() 8 end
  def cmp(other) to_ruby <=> other.to_ruby end
  def packio(x)
    x << [to_i].pack("Q")
  end
  def self.unpackio(str)
    UInt64.new str.read(max_size).unpack("Q")[0]
  end
end

class Int8 < CauterizeBuiltinInteger
  def in_range(v) (v >= -2**7) && (v < 2**7) end
  def self.max_size() 1 end
  def cmp(other) to_ruby <=> other.to_ruby end
  def packio(x)
    x << [to_i].pack("c")
  end
  def self.unpackio(str)
    Int8.new str.read(max_size).unpack("c")[0]
  end
end

class Int16 < CauterizeBuiltinInteger
  def in_range(v) (v >= -2**15) && (v < 2**15) end
  def self.max_size() 2 end
  def cmp(other) to_ruby <=> other.to_ruby end
  def packio(x)
    x << [to_i].pack("s")
  end
  def self.unpackio(str)
    Int16.new str.read(max_size).unpack("s")[0]
  end
end

class Int32 < CauterizeBuiltinInteger
  def in_range(v) (v >= -2**31) && (v < 2**31) end
  def self.max_size() 4 end
  def cmp(other) to_ruby <=> other.to_ruby end
  def packio(x)
    x << [to_i].pack("l")
  end
  def self.unpackio(str)
    Int32.new str.read(max_size).unpack("l")[0]
  end
end

class Int64 < CauterizeBuiltinInteger
  def in_range(v) (v >= -2**63) && (v < 2**63) end
  def self.max_size() 8 end
  def cmp(other) to_ruby <=> other.to_ruby end
  def packio(x)
    x << [to_i].pack("q")
  end
  def self.unpackio(str)
    Int64.new str.read(max_size).unpack("q")[0]
  end
end

class Bool < CauterizeBuiltinBool
  def in_range(v) true end
  def self.max_size() 1 end
  def cmp(other)
    return 0 if to_ruby == other.to_ruby
    return 1 if to_ruby
    return -1
  end
  def packio(x)
    x << if @val
           [1].pack("C")
         else
           [0].pack("C")
         end
  end
  def self.unpackio(str)
    if str.read(max_size).unpack("C")[0] == 0
      Bool.new false
    else
      Bool.new true
    end
  end
end

class Float32 < CauterizeBuiltinFloat
  def in_range(v) [v].pack("f").unpack("f").first.finite? end
  def self.max_size() 4 end
  def cmp(other) to_ruby <=> other.to_ruby end
  def packio(x)
    x << [to_f].pack("f")
  end
  def self.unpackio(str)
    Float32.new str.read(max_size).unpack("f")[0]
  end
end

class Float64 < CauterizeBuiltinFloat
  def in_range(v) true end
  def self.max_size() 8 end
  def cmp(other) to_ruby <=> other.to_ruby end
  def packio(x)
    x << [to_f].pack("d")
  end
  def self.unpackio(str)
    Float64.new str.read(max_size).unpack("d")[0]
  end
end



