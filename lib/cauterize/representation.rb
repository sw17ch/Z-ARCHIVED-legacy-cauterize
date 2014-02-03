class Representation
  def self.lengthRepresentation(max_length)
    if max_length < 2**8
      Cauterize::BaseType.find_type!(:uint8)
    elsif max_length < 2**16
      Cauterize::BaseType.find_type!(:uint16)
    elsif max_length < 2**32
      Cauterize::BaseType.find_type!(:uint32)
    elsif max_length < 2**64
      Cauterize::BaseType.find_type!(:uint64)
    else
      raise Exception.new("Unable to represent array length (#{max_length}).")
    end
  end

  def self.enumRepresentation(args)
    max_val = args[:max]
    min_val = args[:min]
    
    if -128 <= min_val and max_val <= 127
      Cauterize::BaseType.find_type!(:int8)
    elsif (-32768 <= min_val and max_val <= 32767)
      Cauterize::BaseType.find_type!(:int16)
    elsif (-2147483648 <= min_val and max_val <= 2147483647)
      Cauterize::BaseType.find_type!(:int32)
    elsif (-9223372036854775808 <= min_val and max_val <= 9223372036854775807)
      Cauterize::BaseType.find_type!(:int64)
    else
      raise Exception.new("Unable to represent enumeration (#{min_val} -> #{max_val})")
    end
  end
end
