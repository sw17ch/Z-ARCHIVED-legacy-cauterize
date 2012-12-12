class Group
  @@groups = {}
  def self.groups; @@groups end
  def self.find(g); @@groups[g] end
  def self.create(name)
    @@groups[name] = Group.new(name)
  end

  def initialize(name)
    @name = name
    @members = {}
  end

  def member(name, type)
    @members[name] = find_type!(type)
  end

  def prototype(formatter)
    formatter << "struct #{@name};"
  end

  def definition(formatter)
    formatter << "struct #{@name}"
    formatter.braces do
      formatter << "#{enum_type} type;"
      formatter << "union"
      formatter.braces do
        @members.each_pair do |name, defn|
          defn.declare(formatter, name.to_s)
        end
      end
      formatter.append(" data;")
    end
    formatter.append(";")
  end

  def enum_definition(formatter)
    formatter << enum_type
    formatter.braces do
      @members.keys.each do |k|
        formatter << "#{@name}_#{k}".up_snake + ","
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

  def packer_definition(formatter)
    formatter << packer_signature
    formatter.braces do
      # TODO: Eventually, we'll want to validate the tag.
      formatter << "CAUTERIZE_STATUS_T s;"
      formatter.blank_line
      
    end
  end

  def unpacker_definition(formatter)
    raise :unimplemented
  end

  def packer_sym
    "Pack_#{@name}"
  end

  def unpacker_sym
    "Unpack_#{@name}"
  end

  private

  def enum_type
    "enum #{@name}_type"
  end

  def packer_signature
    "CAUTERIZE_STATUS_T #{packer_sym}(struct Cauterize * dst, struct #{@name} * src)"
  end

  def unpacker_signature
    "CAUTERIZE_STATUS_T #{unpacker_sym}(struct #{@name} * dst, struct Cauterize * src)"
  end
end
