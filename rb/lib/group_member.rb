class GroupMember
  attr_reader :name, :sizeFunc

  def self.from_obj(obj)
    if obj.class == Hash
      validate(obj, "name")
      GroupMember.new(obj["name"], obj["size"])
    else
      GroupMember.new(obj)
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

