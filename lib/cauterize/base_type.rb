module Cauterize
  class BaseType
    attr_reader :name, :id
    @@next_id = {}
    @@instances = {}

    def initialize(name)
      @name = name
      @id = next_id
      register_instance(self)
    end

    def type
      tag_part = ((tag << BaseType.id_bit_width) & BaseType.tag_bit_mask)
      id_part  = (id & BaseType.id_bit_mask)
      (tag_part | id_part) & BaseType.type_bit_mask
    end

    def type_str
      "0x%04X" % type
    end

    def tag
      cname = self.class.name
      case cname
      when "Cauterize::Atom";          0
      when "Cauterize::Enumeration";   1
      when "Cauterize::Composite";     2
      when "Cauterize::FixedArray";    3
      when "Cauterize::VariableArray"; 4
      when "Cauterize::Group";         5
      else
        raise Exception.new("Tag not defined for #{cname}.")
      end
    end

    def self.tag_bit_mask;  0xE000 end
    def self.tag_bit_width;      3 end
    def self.id_bit_mask;   0x1FFF end
    def self.id_bit_width;      13 end
    def self.type_bit_mask; 0xFFFF end
    def self.type_bit_width; tag_bit_width + id_bit_width end
    def self.all_instances; @@instances.values end

    def self.find_type(name)
      @@instances[name]
    end

    def self.find_type!(name)
      unless t = find_type(name)
        raise Exception.new("The name #{name} does not correspond to a type.")
      else
        return t
      end
    end

    alias :orig_method_missing :method_missing

    def method_missing(sym, *args)
      m = sym.to_s.match /is_([^\?]+)\?/
      if m
        return ("Cauterize::#{m[1].camel}" == self.class.name)
      else
        orig_method_missing(sym, *args)
      end
    end

    protected

    def register_instance(inst)
      if @@instances[inst.name]
        raise Exception.new("Type with name #{inst.name} already defined.")
      end

      @@instances[inst.name] = inst
    end

    def next_id
      cname = self.class.name
      @@next_id[cname] ||= 0

      an_id = @@next_id[cname]
      @@next_id[cname] += 1
      return an_id
    end
  end
end
