module Cauterize
  def group(name)
    a = groups[name] || groups[name] = Group.new(name)
    yield a if block_given?
    return a
  end

  def group!(name, &blk)
    if groups[name]
      raise Exception.new("Group with name #{name} already exists.")
    else
      group(name, &blk)
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
  end

  class Group < BaseType
    attr_reader :fields

    def initialize(name)
      super
      @fields = {}
    end

    def field(name, type)
      if @fields[name]
        raise Exception.new("Field name #{name} already used.")
      else
        @fields[name] = GroupField.new(name, type)
      end
    end
  end
end
