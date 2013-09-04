require 'stringio'

module CauterizeRuby
  class Data
    @@specializers = Hash.new { |h, k| k }

    def self.set_specializer(c)
      @@specializers[self] = c
    end

    def self.do_construct(x)
      if x.is_a? Data
        raise "Invalid Type: was #{x.class}, expected #{self}" if not x.is_a?(self)
        x
      else
        self.new x
      end
    end

    def self.construct(x)
      @@specializers[self].do_construct(x)
    end

    def self.unpackio(x)
      @@specializers[self].do_unpackio(x)
    end

    def pack
      x = ""
      packio(x)
      x
    end

    def self.unpack(x)
      self.unpackio(StringIO.new(x))
    end

    def ==(other)
      (self <=> other) == 0
    end

    #this promotes 'other' to a cauterize type if it's not one already
    #   this way 'cmp' can always assume 'other' is of the same type
    def <=>(other)
      cmp(self.class.construct(other))
    end
  end

  class Builtin < Data
    def initialize(val)
      @val = val
    end
    def to_ruby
      @val
    end
    # for builtins max_size == min_size
    def self.min_size() max_size end
    def num_bytes() self.class::max_size end
  end

  class BuiltinInteger < Builtin
    def initialize(val)
      #this will always set @val to a regular ruby Fixnum
      super(val.to_i)
    end

    def to_i
      @val
    end

    def to_f
      @val.to_f
    end
  end

  class BuiltinFloat < Builtin
    def initialize(val)
      #this will always set @val to a regular ruby float
      super(val.to_f)
    end

    def to_f
      @val
    end

    def to_i
      @val.to_i
    end
  end

  class BuiltinBool < Builtin
    def initialize(val)
      #this will always set @val to a regular ruby boolean value
      super((val)? true : false)
    end
  end


  class Scalar < Data
    attr_reader :builtin
    def initialize(val)
      # @builtin is going to be some form of Builtin
      @builtin = self.class.builtin.construct val
      raise "#{self.class}: Out of range value: #{@builtin.to_ruby}, for #{self.class}" if not @builtin.in_range(@builtin.to_ruby)
    end

    def to_ruby
      @builtin.to_ruby
    end

    def to_i
      @builtin.to_i
    end

    def to_f
      @builtin.to_f
    end

    def packio(x)
      @builtin.packio(x)
    end

    def self.do_unpackio(str)
      self.new self.builtin.unpackio(str)
    end

    def cmp(other)
      @builtin <=> other.builtin
    end

    def num_bytes() @builtin.num_bytes end
    def self.max_size() builtin::max_size end
    def self.min_size() builtin::min_size end
  end

  class Array < Data

    include Enumerable

    def initialize(elems)
      if elems.is_a? String
        # a special case for strings
        initialize_arr(elems.unpack("C*"))
      else
        initialize_arr(elems)
      end
    end

    def each
      elems.each do |e|
        yield e
      end
    end

    def to_ruby
      @elems.map{|e| e.to_ruby}
    end

    def to_string
      to_ruby.to_a.pack("C*")
    end

    def cmp(other)
      elems <=> other.elems
    end
  end

  class FixedArray < Array
    attr_reader :elems

    def initialize_arr(elems)
      @elems = elems.map { |e| self.class.elem_type.construct(e) }
      raise "#{self.class}: Invalid length: #{@elems.length}, expected: #{self.class.length}" if @elems.length != self.class.length
    end

    def packio(x)
      elems.each do |e|
        e.packio(x)
      end
    end

    def self.do_unpackio(str)
      self.new (1..self.length).map { self.elem_type.unpackio(str) }
    end

    def num_bytes() elems.reduce(0) {|sum, e| sum + e.num_bytes} end
    def self.max_size() length * elem_type::max_size end
    def self.min_size() length * elem_type::min_size end
  end


  class VariableArray < Array
    attr_reader :length
    attr_reader :elems

    def initialize_arr(elems)
      @elems = elems.map { |e| self.class.elem_type.construct(e) }
      @length = self.class.size_type.new @elems.length
      raise "#{self.class}: Invalid length: #{@elems.length}, max length is: #{self.class.max_length}" if @elems.length > self.class.max_length
    end

    def packio(x)
      @length.packio(x)
      @elems.each do |e|
        e.packio(x)
      end
    end
   
    def self.do_unpackio(str)
      length = self.size_type.unpackio(str)
      self.new (1..length.to_i).map { self.elem_type.unpackio(str) }
    end

    def num_bytes() length.num_bytes + elems.reduce(0) {|sum, e| sum + e.num_bytes} end
    def self.max_size() size_type::max_size + (max_length * elem_type::max_size) end
    def self.min_size() size_type::min_size end
  end


  class Composite < Data
    attr_reader :fields

    def initialize(field_values)
      missing_keys = self.class.fields.keys - field_values.keys
      extra_keys = field_values.keys - self.class.fields.keys
      bad_init = !extra_keys.empty? || !missing_keys.empty?
      raise "#{self.class}: Invalid initialization params, missing fields: #{missing_keys}, extra fields: #{extra_keys}" if bad_init
      @fields = Hash[self.class.fields.keys.map do |field_name|
        [field_name, self.class.fields[field_name].construct(field_values[field_name])]
      end]
    end

    def to_ruby
      Hash[@fields.map{|name, value| [name, value.to_ruby]}]
    end

    def packio(x)
      @fields.values.each do |v|
        v.packio(x)
      end
    end

    def self.do_unpackio(str)
      self.new Hash[self.fields.keys.map do |k|
        [k, self.fields[k].unpackio(str)]
      end]
    end

    def cmp(other)
      fields.values <=> other.fields.values
    end

    def num_bytes
      fields.values.reduce(0) {|sum, v| sum + v.num_bytes}
    end

    def self.max_size
      fields.values.reduce(0) {|sum, v| sum + v::max_size}
    end

    def self.min_size
      fields.values.reduce(0) {|sum, v| sum + v::min_size}
    end
  end


  class Enumeration < Data
    attr_reader :field_name

    def initialize(field_name)
      raise "#{self.class}: Invalid field name: #{field_name}, Valid field names are: #{self.class.fields.keys}" if not self.class.fields.keys.include?(field_name)
      @field_name = field_name
    end

    def to_ruby
      @field_name
    end

    def to_i() self.class.fields[@field_name] end

    def packio(x)
      self.class.repr_type.construct(self.class.fields[@field_name]).packio(x)
    end

    def self.from_int(i)
      raise "#{self}: Invalid enumeration value: #{i.to_i}" if not self.fields.values.include? i.to_i
      self.new(self.fields.invert[i.to_i])
    end

    def self.do_unpackio(str)
      self.from_int(self.repr_type.unpackio(str).to_i)
    end

    def cmp(other)
      to_i <=> other.to_i
    end

    def num_bytes() self.class.repr_type::max_size end
    def self.max_size() repr_type::max_size end
    def self.min_size() repr_type::min_size end
  end


  class Group < Data
    attr_reader :tag
    attr_reader :data

    def to_ruby
      if data.nil?
        { tag: tag_field_name }
      else
        { tag: tag_field_name,
          data: data.to_ruby }
      end
    end

    def tag_field_name
      self.class.from_tag_field_name(@tag.field_name)
    end

    def self.tag_from_field_name(field_name)
      self.tag_type.construct((self.tag_prefix + field_name.to_s).to_sym)
    end

    def self.from_tag_field_name(tag_name)
      t = tag_name.to_s
      t.slice!(self.tag_prefix)
      t.to_sym
    end
    
    def initialize(h)
      @tag = self.class.tag_from_field_name(h[:tag])
      field_class = self.class.fields[tag_field_name]
      @data = (field_class.nil?) ? nil : field_class.construct(h[:data])
    end

    def packio(x)
      @tag.packio(x)
      @data.packio(x) unless @data.nil?
    end

    def self.do_unpackio(str)
      tag = self.tag_type.unpackio(str)
      field_name = self.from_tag_field_name(tag.field_name)
      data_type = self.fields[field_name]
      if data_type.nil?
        self.new({ tag: field_name })
      else
        self.new({ tag: field_name, data: data_type.unpackio(str) })
      end
    end

    def cmp(other)
      r = (tag <=> other.tag)
      if r == 0
        data <=> other.data
      else
        r
      end
    end

    def num_bytes() tag.num_bytes + ((data.nil?) ? 0 : data.num_bytes) end

    def self.max_size() tag_type::max_size + fields.values.map{|v| (v.nil?) ? 0 : v::max_size}.max end
    def self.min_size() tag_type::min_size + fields.values.map{|v| (v.nil?) ? 0 : v::min_size}.min end
  end
end
