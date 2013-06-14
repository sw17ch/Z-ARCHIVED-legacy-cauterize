require 'bindata'
require 'cauterize/snake_case'
require 'cauterize/base_type'
require 'cauterize/cauterize'

def populate_scalar(inst)
  Class.new(BinData::Record) do |c|
    c.send(:endian, :little)
    c.send(inst.type_name.name.to_sym, :data)
  end
end

def populate_enum(inst)
  Class.new(BinData::Record) do |c|
    c.send(:endian, :little)
    c.send(inst.representation.name.to_sym, :representation)

    enum_vals = inst.values.values.map {|v| [v.value, v.name.to_sym]}
    enum_hash = Hash[enum_vals]
    c.const_set(:ENUM_MAP, enum_hash)

    def enum
      self.class.const_get(:ENUM_MAP)[representation]
    end
  end
end

def populate_fixed_array(inst)
  Class.new(BinData::Record) do |c|
    c.send(:endian, :little)
    c.send(:array, :data, { :type => :color,
                            :initial_length => inst.array_size })
  end
end
 
module Cauterize
  def self.populate(desc_file)
    parse_dsl(desc_file)

    dsl_mod = Module.new do |mod|
      BaseType.all_instances.each do |inst|
        i_class = case inst.class.name
        when "Cauterize::Scalar"
          populate_scalar(inst)
        when "Cauterize::Enumeration"
          populate_enum(inst)
        when "Cauterize::FixedArray"
          # populate_fixed_array(inst)
        when "Cauterize::BuiltIn"
          # ignored
        else
          puts "Unhandled instance: #{inst.class.name}"
          nil
        end

        mod.const_set(inst.name.to_s.camel, i_class)
      end
    end

    const_set(Cauterize.get_name.camel, dsl_mod)
  end
end

