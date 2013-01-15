module Cauterize
  module_function

  def group(name)
    a = Cauterize.groups[name] || Cauterize.groups[name] = Group.new(name)
    yield a if block_given?
    return a
  end

  def group!(name, &blk)
    if Cauterize.groups[name]
      raise Exception.new("Group with name #{name} already exists.")
    else
      Cauterize.group(name, &blk)
    end
  end

  def groups
    @groups ||= {}
  end

  class GroupField
    attr_reader :name, :type

    def initialize(name, type)
      @name = name
      @type = BaseType.find_type!(type)
    end

    def enum_sym
    end
  end

  class Group < BaseType
    attr_reader :fields, :tag_enum

    def initialize(name)
      super
      @fields = {}
      @tag_enum = Cauterize.enumeration!("group_#{name}_type".to_sym)
    end

    def field(name, type)
      if @fields[name]
        raise Exception.new("Field name #{name} already used.")
      else
        @fields[name] = GroupField.new(name, type)
        @tag_enum.value(enum_sym(name))
      end
    end

    def enum_sym(fname)
      "group_#{@name}_type_#{fname}".up_snake.to_sym
    end
  end
end
