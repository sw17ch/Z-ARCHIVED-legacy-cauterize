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

class Group
  def self.from_hash(hash)
    validate(hash, "group")
    group = hash["group"]
    validate(group, "name", "members")

    Group.new(group["name"], group["members"])
  end

  def initialize(name, members)
    @name = name
    @members = members
  end

  def enum_type
    "enum #{cap_name}"
  end

  def cap_name
    "GROUP_" + @name.up_snake
  end

  def member_enums
      enum_to_member_map.keys
  end

  def enum_to_member_map
    @etmm ||= {}.tap do |h|
      @members.map do |m|
        h[m] = "#{cap_name}_#{m.up_snake}"
      end
    end
  end

  def format_enumeration(formatter)
    formatter.enum(cap_name) do |f|
      member_enums.each {|m| f << "#{m},"}
    end
    formatter.blank_line
  end

  def format_struct(formatter)
    formatter.struct(@name) do |f|
      f << "#{enum_type} tag;"
      f.braces("union") do |g|
        @members.each {|m| g << "struct #{m} #{m.down_snake};"}
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
        enum_to_member_map.each_pair do |m, e|
          f.undented { f << "case #{e}:"}
          field = "s->data.#{m.down_snake}"
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

