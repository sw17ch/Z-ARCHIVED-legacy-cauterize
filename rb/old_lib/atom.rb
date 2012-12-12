class Atom
  @@atoms = {}
  def self.atoms; @@atoms end
  def self.find(a); @@atoms[a] end
  def self.create(name)
    check_type(name)
    @@atoms[name] = Atom.new(name)
  end

  attr_accessor :len_fun

  def initialize(name)
    @name = name
    @len_fun = "sizeof(*(?))"
  end

  def declare(formatter, decl, array_size=nil)
    d = "#{@name} #{decl}"
    if array_size
      d += "[#{array_size}]"
    end
    formatter << d + ";"
  end

  def packer_prototype(formatter)
    formatter << packer_signature + ";"
  end

  def unpacker_prototype(formatter)
    formatter << unpacker_signature + ";"
  end

  def packer_declaration(formatter)
    formatter << packer_signature
    formatter.braces do
      formatter << "return CauterizeAppend(dst, (uint8_t*)src, #{interp(@len_fun, "src")});"
    end
  end

  def unpacker_declaration(formatter)
    formatter << unpacker_signature
    formatter.braces do
      formatter << "return CauterizeRead(src, (uint8_t*)dst, #{interp(@len_fun, "dst")});"
    end
  end

  def packer_sym
    "Pack_#{@name}"
  end

  def unpacker_sym
    "Unpack_#{@name}"
  end

  private

  def packer_signature
    "CAUTERIZE_STATUS_T #{packer_sym}(struct Cauterize * dst, #{@name} * src)"
  end

  def unpacker_signature
    "CAUTERIZE_STATUS_T #{unpacker_sym}(#{@name} * dst, struct Cauterize * src)"
  end
end
