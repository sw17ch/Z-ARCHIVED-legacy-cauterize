require 'set'

module Cauterize
  class BaseType
    attr_reader :name, :id, :description
    @@next_id = {}
    @@instances = {}

    def initialize(name, description=nil)
      if @@instances.keys.include?(name)
        raise Exception.new("A type with the name #{name} already exists. [#{@@instances[name].inspect}]")
      end

      @name = name
      @description = description
      @id = next_id
      register_instance(self)
    end

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
