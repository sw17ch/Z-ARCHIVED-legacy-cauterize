class String
  def snake
    self.gsub(/::/, '/').
    gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
    gsub(/([a-z\d])([A-Z])/,'\1_\2').
    tr("-", "_")
  end

  def up_snake
    snake.upcase
  end

  def down_snake
    snake.downcase
  end
end

class Member
  attr_reader :name, :sizeFunc

  def self.from_obj(obj)
    if obj.class == Hash
      Member.new(obj["name"], obj["size"])
    else
      Member.new(obj)
    end
  end

  def initialize(name, sizeFunc=nil)
    @name = name
    @sizeFunc = sizeFunc
  end

  def enum_name(prefix="")
    prefix + @name.up_snake
  end
end

class Group
  def self.from_hash(hash)
    validate(hash, "group")
    group = hash["group"]
    validate(group, "name", "members")

    Group.new(group["name"], group["members"])
  end

  def initialize(name, members)
    @name = name
    @members = members.map {|m| Member.from_obj(m)}
  end

  def enum_type
    "enum #{up_name}"
  end

  def up_name
    "GROUP_" + @name.up_snake
  end

  def name_as_prefix
    up_name + "_"
  end

  def format_enumeration(formatter)
    formatter.enum(up_name) do |f|
      member_enums = @members.map {|m| m.enum_name(name_as_prefix)}
      member_enums.each {|m| f << "#{m},"}
    end
    formatter.blank_line
  end

  def format_struct(formatter)
    formatter.struct(@name) do |f|
      f << "#{enum_type} tag;"
      f.braces("union") do |g|
        @members.each {|m| g << "struct #{m.name} #{m.name.down_snake};"}
      end
      formatter.append_last(" data;")
    end
    formatter.blank_line
  end

  def format_packer(formatter)
    params = [ "struct Cauterize * c", "struct #{@name} * s" ]
    formatter.func("Pack#{@name}", "CAUTERIZE_STATUS_T", params) do |f|
      f << "CAUTERIZE_STATUS_T s;"
      f.blank_line

      # Copy the tag.
      f << "s = CauterizeAppend(c, &(s->tag), sizeof(s->tag));"
      f.braces("if (CA_OK != s)") do
        f << "return s;"
      end
      f.blank_line

      # Copy the union.
      f.braces("switch (s->tag)") do
        @members.each do |m|
          f.undented { f << "case #{m.enum_name(name_as_prefix)}:"}
          field = "s->data.#{m.name.down_snake}"
          f << "s = CauterizeAppend(c, &(#{field}), sizeof(#{field}));"
          f.braces("if (CA_OK != s)") do
            f << "return s;"
          end
          f << "break;"
          f.blank_line
        end
      end
      f << "return CA_OK;"
    end
    formatter.blank_line
  end

  def unpacker(formatter)
    raise :unimplemented
  end
end

