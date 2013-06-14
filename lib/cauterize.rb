require 'bindata'
require 'cauterize/snake_case'
require 'cauterize/base_type'
require 'cauterize/cauterize'

def populate_scalar(klass, inst)
  klass.class_eval do
    send(:endian, :little)
    send(inst.type_name.name.to_sym, :data)
  end
end

def populate_enum(klass, inst)
  klass.class_eval do
    send(:endian, :little)

    send(inst.representation.name.to_sym, :representation)

    enum_vals = inst.values.values.map {|v| [v.value, v.name.to_sym]}
    enum_hash = Hash[enum_vals]
    const_set(:ENUM_MAP, enum_hash)

    def enum
      self.class.const_get(:ENUM_MAP)[representation]
    end
  end
end

def populate_fixed_array(klass, inst)
  klass.class_eval do
    send(:array, :data, { :type => inst.array_type.name,
                          :initial_length => inst.array_size })
  end
end

def populate_variable_array(klass, inst)
  # TODO: Figure out what we should do with inst.array_size
  klass.class_eval do
    send(inst.size_type.name, :va_len, :value => lambda { data.length })
    send(:array, :data, { :type => inst.array_type.name,
                          :read_until => lambda { index == length }} )
  end
end

def populate_composite(klass, inst)
  klass.class_eval do
    send(:endian, :little)
    inst.fields.values.each do |v|
      send(v.type.name.to_s, v.name.to_s)
    end
  end
end

def populate_group(klass, inst)
  choices = inst.fields.values.each_with_index.map do |v, i|
    [i, v.type.nil? ? :empty_data : v.type.name.to_s.to_sym]
  end

  klass.class_eval do
    send(:endian, :little)
    send(inst.tag_enum.name.to_s, :tag)

    send(:choice, :data, :selection => lambda { tag.representation },
                         :choices => Hash[choices] )
  end
end
 
module Cauterize
  class EmptyData < BinData::Record; end

  def self.populate(desc_file)
    parse_dsl(desc_file)

    dsl_mod = Module.new do |mod|

      BaseType.all_instances.each do |inst|
        next if "Cauterize::BuiltIn" == inst.class.name

        n = inst.name.to_s.camel
        module_eval("class #{n} < BinData::Record; end")
        klass = const_get(n)

        case inst.class.name
        when "Cauterize::Scalar"
          populate_scalar(klass, inst)
        when "Cauterize::Enumeration"
          populate_enum(klass, inst)
        when "Cauterize::FixedArray"
          populate_fixed_array(klass, inst)
        when "Cauterize::VariableArray"
          populate_variable_array(klass, inst)
        when "Cauterize::Composite"
          populate_composite(klass, inst)
        when "Cauterize::Group"
          populate_group(klass, inst)
        else
          puts "Unhandled instance: #{inst.class.name}"
        end
      end
    end

    const_set(Cauterize.get_name.camel, dsl_mod)
  end
end

