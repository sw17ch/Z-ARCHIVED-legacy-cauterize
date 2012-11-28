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

  def format_enumeration(formatter)
    formatter.enum(cap_name) do |f|
      @members.each {|m| f << "#{cap_name}_#{m.up_snake}," }
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
end

