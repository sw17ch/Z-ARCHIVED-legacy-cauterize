class Composite
  @@composites = {}
  def self.composites; @@composites end
  def self.find(c); @@composites[c] end
  def self.create(name)
    check_type(name)
    @@composites[name] = Composite.new(name)
  end

  def initialize(name)
    @name = name
    @fields = {}
    @size_maps = {}
  end

  def field(name, type)
    @fields[name] = (f = Field.new(name, type))
    yield f if block_given?
  end

  def size_map(size_of, size_def)
    # Check that it makes sense to have a size assigned to this field
    unless @fields[size_of].count
      raise Exception.new("Cannot specify size map on non-array field #{size_of}.")
    end
    # Check that the keys are properly ordered for this mapping.
    unless @fields.keys.drop_while{|y| y != size_def}.any? {|y| y == size_of}
      raise Exception.new("Invalid size mapping: #{size_of} => #{size_def}")
    end

    @size_maps[size_of] = size_def
  end

  def prototype(formatter)
    formatter << "struct #{@name};"
  end

  def declare(formatter, decl, array_size=nil)
    d = "struct #{@name} #{decl}"
    d += "[#{array_size.to_i}]" if array_size
    formatter << d + ";"
  end

  def definition(formatter)
    formatter << "struct #{@name}"
    formatter.braces do
      @fields.each_pair do |name, field|
        field.declare(formatter)
      end
    end
    formatter.append(";")
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
      formatter << "CAUTERIZE_STATUS_T err;"
      formatter << "uint32_t i;" if @fields.values.any? {|f| f.count}
      formatter.blank_line
      @fields.each_pair do |name, field|
        if field.count
          size_map = @size_maps[name]

          if size_map
            count = "src->#{size_map.to_s}"
            formatter << "if (#{count} > #{field.count.to_s}) { return CA_ERR_INVALID_LENGTH; }"
          else
            count = field.count.to_s
          end

          formatter << "for (i = 0; i < #{count}; i++)"
          formatter.braces do
            formatter << "if (CA_OK != (err = #{field.type.packer_sym}(dst, &src->#{name}[i]))) { return err; }"
          end
        else
          formatter << "if (CA_OK != (err = #{field.type.packer_sym}(dst, &src->#{name}))) { return err; }"
        end
      end
      formatter.blank_line
      formatter << "return CA_OK;"
    end
  end

  def unpacker_declaration(formatter)
    formatter << unpacker_signature
    formatter.braces do
      formatter << "CAUTERIZE_STATUS_T err;"
      formatter << "uint32_t i;" if @fields.values.any? {|f| f.count}
      formatter.blank_line
      @fields.each_pair do |name, field|
        if field.count
          size_map = @size_maps[name]

          if size_map
            count = "dst->#{size_map.to_s}"
            formatter << "if (#{count} > #{field.count.to_s}) { return CA_ERR_INVALID_LENGTH; }"
          else
            count = field.count.to_s
          end

          formatter << "for (i = 0; i < #{count}; i++)"
          formatter.braces do
            formatter << "if (CA_OK != (err = #{field.type.unpacker_sym}(&dst->#{name}[i], src))) { return err; }"
          end
        else
          formatter << "if (CA_OK != (err = #{field.type.unpacker_sym}(&dst->#{name}, src))) { return err; }"
        end
      end
      formatter.blank_line
      formatter << "return CA_OK;"
    end
  end

  def packer_sym
    "Pack_struct_#{@name}"
  end

  def unpacker_sym
    "Unpack_struct_#{@name}"
  end

  private

  def packer_signature
    "CAUTERIZE_STATUS_T #{packer_sym}(struct Cauterize * dst, struct #{@name} * src)"
  end

  def unpacker_signature
    "CAUTERIZE_STATUS_T #{unpacker_sym}(struct #{@name} * dst, struct Cauterize * src)"
  end
end
