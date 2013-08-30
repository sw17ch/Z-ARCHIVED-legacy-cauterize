require 'tmpdir'
require 'fileutils'

# require_relative '../support/ruby/src/cauterize_ruby_builtins'
# require_relative '../support/ruby/src/cauterize_ruby_baseclasses'

# Cauterize.set_name("example_project")

def range_test_type(s)
  ("range_test_" + s.to_s)
end

def integer_builtin_type_ranges
  [ [:uint8,      0,  2**8-1], 
    [:int8,   -2**7,  2**7-1], 
    [:uint16,     0,  2**16-1],
    [:int16,  -2**15, 2**15-1],
    [:uint32,     0,  2**32-1],
    [:int32,  -2**31, 2**31-1],
    [:uint64,     0,  2**64-1],
    [:int64,  -2**63, 2**63-1],
  ]
end

def floating_builtin_type_ranges
  [ [:float32,  -3.402823466e38, 3.402823466e38],
    [:float64,  -2.2250738585072014e-308 , 2.2250738585072014e-308 ],
  ]
end

def integer_builtin_types
  integer_builtin_type_ranges.each do |t, min_val, max_val|
    t_class = ExampleProject.const_get(range_test_type(t).camel.to_sym)
    yield t_class, min_val, max_val
  end
end

Cauterize.set_name("example_project")
Cauterize.set_version("1.2.3")

integer_builtin_type_ranges.each do |builtin_type, min_val, max_val| 
  Cauterize.scalar(range_test_type(builtin_type).to_sym) do |t|
    t.type_name(builtin_type)
  end
end

floating_builtin_type_ranges.each do |builtin_type, min_val, max_val| 
  Cauterize.scalar(range_test_type(builtin_type).to_sym) do |t|
    t.type_name(builtin_type)
  end
end

Cauterize.scalar(:small_uint) {|t| t.type_name(:uint8)}

Cauterize.fixed_array(:mac_address) do |fa|
  fa.array_type :small_uint
  fa.array_size 6
end

Cauterize.variable_array(:mac_table) do |t|
  t.array_type :mac_address
  t.array_size 64
  t.size_type :small_uint
end

Cauterize.variable_array(:name) do |va|
  va.array_type :small_uint
  va.size_type :small_uint
  va.array_size 32
end

Cauterize.enumeration(:gender) do |e|
  e.value :male
  e.value :female
end

Cauterize.composite(:place) do |c|
  c.field :name, :name
  c.field :elevation, :uint32
end

Cauterize.composite(:person) do |c|
  c.field :first_name, :name
  c.field :last_name, :name
  c.field :gender, :gender
end

Cauterize.composite(:dog) do |c|
  c.field :name, :name
  c.field :gender, :gender
  c.field :leg_count, :small_uint
end

Cauterize.group(:creature) do |g|
  g.field :person, :person
  g.field :dog, :dog
end

Dir.mktmpdir do |tmpdir|
  @rb_path = File.join(tmpdir, "testing.rb")

  # copy support files into temporary directory
  Dir["support/ruby/src/*"].each do |path|
    FileUtils.cp(path, tmpdir + "/")
  end

  @rb = Cauterize::RubyBuilder.new(@rb_path, "testing")
  @rb.build
  require @rb_path

  puts File.read(@rb.rb)

end

module ExampleProject
  class MacAddress
    alias orig_validate validate
    def validate
      if @raw_data.nil?
        orig_validate
      end
    end

    alias orig_pack pack

    def pack
      if @raw_data.nil?
        orig_pack
      else
        @raw_data
      end
    end

    def self.unpackio(str)
      raw = str.read(self.length)
      data = StringIO.new(raw)

      elems = Enumerator.new do |y|
        (1..self.length).each do
          y << self.elem_type.unpackio(data)
        end
      end
      self.new elems, raw
    end

    alias orig_to_string to_string
    def orig_to_string
      if @raw_data.nil?
        orig_to_string
      else
        @raw_data
      end
    end
  end
end

module ExampleProject
  class Name
    alias orig_validate validate
    def validate
      if @raw_data.nil?
        orig_validate
      end
    end

    alias orig_pack pack

    def pack
      if @raw_data.nil?
        orig_pack
      else
        @length.pack + @raw_data
      end
    end

    def self.unpackio(str)
      length = self.size_type.unpackio(str)
      raw = str.read(length.to_i)
      elems = Enumerator.new do |y|
        data = StringIO.new(raw)
        (1..length.to_i).each do
          y << self.elem_type.unpackio(data)
        end
      end
      self.new elems, raw
    end

    alias orig_to_string to_string
    def orig_to_string
      if @raw_data.nil?
        orig_to_string
      else
        @raw_data
      end
    end
  end
end

module Cauterize
  describe Cauterize::RubyBuilder do
    before(:all) do
      
    end

    after(:all) do
    end

 
    describe CauterizeScalar do

      integer_builtin_types do |c, min_val, max_val|
        describe c do
          it "should be able to store its minimum value" do
            c.new(min_val).to_i.should == min_val
          end

          it "should be able to store its maximum value" do
            c.new(max_val).to_i.should == max_val
          end

          it "should not be able to store #{max_val + 1}" do
            lambda { c.new(max_val + 1)}.should raise_error("Out of range value: #{max_val + 1}, for #{c}")
          end

          it "should not be able to store #{min_val - 1}" do
            lambda { c.new(min_val - 1)}.should raise_error("Out of range value: #{min_val - 1}, for #{c}")
          end

          it "should be able to pack and unpack back to its original value" do
            # p c.new(max_val).pack
            # p c.unpack(c.new(max_val).pack).class
            c.unpack(c.new(max_val).pack).to_i.should == max_val
          end
        end
      end

    end

    describe CauterizeVariableArray do
      it "can be constructed from an existing variable array of same type" do
        test_string = "this is a test"
        test_array = ExampleProject::Name.new(test_string.bytes) 
        new_array = ExampleProject::Name.new(test_array)
        new_array.to_ruby.should == test_string.bytes.to_a
      end

      it "can pack, and unpack to its original value" do
        test_string = "this is a test"
        ExampleProject::Name.unpack(ExampleProject::Name.new(test_string.bytes).pack).to_string.should == test_string
      end
    end

    describe CauterizeFixedArray do

      it "can be constructed from an existing fixed array of same type" do
        expected_array = [1, 2, 6, 10, 100, 0]
        test_array = ExampleProject::MacAddress.new(expected_array) 
        new_array = ExampleProject::MacAddress.new(test_array)
        new_array.to_ruby.should == expected_array
      end

      it "can pack, and unpack to its original value" do
        test_array = [1, 2, 6, 10, 100, 0]
        ExampleProject::MacAddress.unpack(ExampleProject::MacAddress.new(test_array).pack).to_ruby.should == test_array
      end
    end

  end
end
