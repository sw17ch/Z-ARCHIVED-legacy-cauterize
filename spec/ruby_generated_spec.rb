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
  [ [:float32,  -3.4028234e38, 3.4028234e38],
    [:float64,  Float::MIN, Float::MAX ],
  ]
end

def integer_builtin_types
  integer_builtin_type_ranges.each do |t, min_val, max_val|
    t_class = ExampleProject.const_get(range_test_type(t).camel.to_sym)
    yield t_class, min_val, max_val
  end
end

def floating_builtin_types
  floating_builtin_type_ranges.each do |t, min_val, max_val|
    t_class = ExampleProject.const_get(range_test_type(t).camel.to_sym)
    yield t_class, min_val, max_val
  end
end

def numeric_builtin_types
  integer_builtin_types do |t, min_val, max_val| 
    yield t, min_val, max_val
  end
  floating_builtin_types do |t, min_val, max_val|
    yield t, min_val, max_val
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

Cauterize.scalar(:a_test_bool) {|t| t.type_name(:bool)}
Cauterize.scalar(:a_test_float) {|t| t.type_name(:float32)}

# Cauterize.fixed_array(:simple_integer_fixed_array) do |fa|
#   fa.array_type :uint8
#   fa.array_size 5
# end

# Cauterize.fixed_array(:simple_integer_fixed_array) do |fa|
#   fa.array_type :uint8
#   fa.array_size 5
# end
Cauterize.enumeration(:color) do |e|
  e.value :red
  e.value :blue
  e.value :green
end

Cauterize.enumeration(:wacky_enum) do |e|
  e.value :negative, -500
  e.value :negative_plus_one
  e.value :positive, 500
  e.value :positive_plus_one
end

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

class FastName < CauterizeData
  attr_reader :length
  def initialize(raw_data)
    @raw_data = raw_data.to_s
    @length = ExampleProject::Name.size_type.construct(@raw_data.length)
    raise "Invalid length: #{@raw_data.length}, max length is: #{ExampleProject::Name.max_length}" if @raw_data.length > ExampleProject::Name.max_length
  end

  def to_string
    @raw_data
  end

  alias to_ruby to_string
  alias pack to_string

  def packio(x)
    x << length.pack
    x << @raw_data
  end

  def self.do_unpackio(x)
    len = ExampleProject::Name.size_type.unpackio(x)
    self.new(x.read(len.to_ruby))
  end
end

ExampleProject::Name.set_specializer(FastName)

module Cauterize
  describe Cauterize::RubyBuilder do
    before(:all) do
      
    end

    after(:all) do
    end
 
    describe CauterizeScalar do

      numeric_builtin_types do |c, min_val, max_val|
        describe c do
          it "should be able to store its minimum value" do
            c.new(min_val).to_ruby.should == min_val
          end
          it "should be able to store its maximum value" do
            c.new(max_val).to_ruby.should == max_val
          end
          it "can construct from existing #{c}" do
            existing = c.new(max_val)
            c.construct(existing).to_ruby.should == max_val
          end
          it "pack and unpack should be inverses" do
            c.unpack(c.new(123).pack).to_ruby.should == 123
          end
          it "to_i should result in an Integer" do
            c.new(max_val).to_i.is_a?(Integer).should be_true
          end
          it "to_f should result in a Float" do
            c.new(max_val).to_f.class.should == Float
          end
          it "min val should be smaller than max val" do
            (c.new(min_val) <=> max_val).should == -1
            (c.new(min_val) <=> c.new(max_val)).should == -1
          end
          it "max val should be bigger than min val" do
            (c.new(max_val) <=> min_val).should == 1
            (c.new(max_val) <=> min_val).should == 1
          end
          it "equal numbers should be equal" do
            (c.new(123) <=> 123).should == 0
            (c.new(123) <=> c.new(123)).should == 0
            (c.new(123) == c.new(123)).should be_true
            (c.new(123) == 123).should be_true
            (c.new(123) != 123).should be_false
            (c.new(123) != c.new(123)).should be_false
            (c.new(123) != c.new(124)).should be_true
            (c.new(123) != 124).should be_true
          end
          it "should raise exception if comparing to wrong cauterize type" do
            thing = ExampleProject::ATestBool.new(false)
            lambda { c.new(123) <=> thing }.should raise_error("Invalid Type: was #{ExampleProject::ATestBool}, expected #{c.name}")
          end
        end
      end

      integer_builtin_types do |c, min_val, max_val|
        describe c do
          it "should not be able to store #{max_val + 1}" do
            lambda { c.new(max_val + 1)}.should raise_error("Out of range value: #{max_val + 1}, for #{c}")
          end
          it "should not be able to store #{min_val - 1}" do
            lambda { c.new(min_val - 1)}.should raise_error("Out of range value: #{min_val - 1}, for #{c}")
          end
          it "to_ruby and to_i and to_f should return the same number" do
            x = c.new(max_val) 
            x.to_i.should == x.to_ruby
            x.to_f.should == x.to_ruby
          end
          it "storing a float should truncate it to an Integer" do
            x = c.new(1.5)
            x.to_f.should == 1.0
          end
          it "to_ruby should result in an Integer" do
            c.new(max_val).to_ruby.is_a?(Integer).should be_true
          end
        end
      end

      floating_builtin_types do |c, min_val, max_val|
        describe c do
          it "to_ruby and to_f should return the same number" do
            x = c.new(max_val) 
            x.to_f.should == x.to_ruby
          end
          it "to_ruby should result in a Float" do
            c.new(max_val).to_ruby.is_a?(Float).should be_true
          end
          it "to_i should return the same number, but truncated" do
            x = c.new(123.532) 
            x.to_i.should == 123
          end
        end
      end

      describe ExampleProject::ATestFloat do
          max_plus = 3.402824e38
          it "should not be able to store #{max_plus}" do
            lambda { ExampleProject::ATestFloat.new(max_plus)}.should raise_error("Out of range value: #{max_plus}, for #{ExampleProject::ATestFloat}")
          end
          min_minus = -3.402824e38
          it "should not be able to store #{min_minus}" do
            lambda { ExampleProject::ATestFloat.new(min_minus)}.should raise_error("Out of range value: #{min_minus}, for #{ExampleProject::ATestFloat}")
          end
      end

      describe ExampleProject::ATestBool do
        it "pack and unpack should be inverses" do
          ExampleProject::ATestBool.unpack(ExampleProject::ATestBool.new(true).pack).to_ruby.should == true
          ExampleProject::ATestBool.unpack(ExampleProject::ATestBool.new(false).pack).to_ruby.should == false
        end
        it "should be construct from existing ATestBool" do
          existing = ExampleProject::ATestBool.new(false)
          ExampleProject::ATestBool.construct(existing).to_ruby.should == false
        end
        it "should be able to store true" do
          ExampleProject::ATestBool.new(true).to_ruby.should == true
        end
        it "should be able to store false" do
          ExampleProject::ATestBool.new(false).to_ruby.should == false
        end
        it "should convert a truthy true" do
          ExampleProject::ATestBool.new([]).to_ruby.should == true
        end
        it "should convert a falsy false" do
          ExampleProject::ATestBool.new(nil).to_ruby.should == false
        end
        it "true should equal true" do
          (ExampleProject::ATestBool.new(true) == true).should be_true
          (ExampleProject::ATestBool.new(true) != true).should be_false
          (ExampleProject::ATestBool.new(true) <=> true).should == 0 
        end
        it "false should equal false" do
          (ExampleProject::ATestBool.new(false) == false).should be_true
          (ExampleProject::ATestBool.new(false) != false).should be_false
          (ExampleProject::ATestBool.new(false) <=> false).should == 0 
        end
        it "false comes before than true" do
          (ExampleProject::ATestBool.new(false) <=> true).should == -1
          (ExampleProject::ATestBool.new(false) <=> ExampleProject::ATestBool.new(true)).should == -1
        end
        it "true comes after false" do
          (ExampleProject::ATestBool.new(true) <=> false).should == 1
          (ExampleProject::ATestBool.new(true) <=> ExampleProject::ATestBool.new(false)).should == 1
        end
      end
    end

    describe CauterizeEnumeration do
      describe ExampleProject::Color do
        example_colors = [:RED, :BLUE, :GREEN]
        example_not_colors = [:DIRT, :LASERS, :HUNGRY, 0, 1.0, true]

        example_colors.each_with_index do |color, i|
          it ".new and .to_ruby should be inverses" do
            ExampleProject::Color.new(color).to_ruby.should == color
          end
          it "pack and unpack should be inverses" do
            ExampleProject::Color.unpack(ExampleProject::Color.new(color).pack).to_ruby.should == color
          end
          it ".to_i should be the value index (in this case)" do
            ExampleProject::Color.new(color).to_i.should == i
          end
          it ".from_int and .to_i should be inverses" do
            ExampleProject::Color.from_int(i).to_i.should == i
          end
        end
        example_not_colors.each do |non_color|
          it "should not be able to construct from non-colors" do
            lambda { ExampleProject::Color.new(non_color)}.should raise_error("Invalid field name: #{non_color}")
          end
        end
        it ".from_int should raise error on invalid input" do
          lambda { ExampleProject::Color.from_int(-1)}.should raise_error("Invalid enumeration value: -1")
          lambda { ExampleProject::Color.from_int(3)}.should raise_error("Invalid enumeration value: 3")
        end
      end
      describe ExampleProject::WackyEnum do
        example_wacky = { NEGATIVE: -500,
                          NEGATIVE_PLUS_ONE: -499,
                          POSITIVE: 500,
                          POSITIVE_PLUS_ONE: 501}
        example_wacky.each do |k, v|
          it ".new and .to_ruby should be inverses" do
            ExampleProject::WackyEnum.new(k).to_ruby.should == k
          end
          it "pack and unpack should be inverses" do
            ExampleProject::WackyEnum.unpack(ExampleProject::WackyEnum.new(k).pack).to_ruby.should == k
          end
          it ".to_i should be the enum value" do
            ExampleProject::WackyEnum.new(k).to_i.should == v 
          end
          it ".from_int and .to_i should be inverses" do
            ExampleProject::WackyEnum.from_int(v).to_i.should == v
          end
        end
        it ".from_int should raise error on invalid input" do
          lambda { ExampleProject::WackyEnum.from_int(0)}.should raise_error("Invalid enumeration value: 0")
          lambda { ExampleProject::WackyEnum.from_int(-498)}.should raise_error("Invalid enumeration value: -498")
        end
        describe "#<=>" do
          example_wacky.each do |k1, v1|
            example_wacky.each do |k2, v2|
              it "should have the same ordering as the enum values" do
                (ExampleProject::WackyEnum.new(k1) <=> ExampleProject::WackyEnum.new(k2)).should == (v1 <=> v2)
              end
            end
          end
        end
      end
      describe "#<=>" do
        it "should automatically promote a symbol when compared against" do
          (ExampleProject::Color.new(:RED) <=> :RED).should == 0
          (ExampleProject::Color.new(:RED) <=> :BLUE).should == -1
          (ExampleProject::Color.new(:BLUE) <=> :RED).should == 1
        end
        it "should raise a type error if compared against a non-symbol or value of different type" do
          lambda { (ExampleProject::Color.new(:RED) <=> 0) }.should raise_error("Invalid field name: 0")
          lambda { (ExampleProject::Color.new(:RED) <=> :ORANGE) }.should raise_error("Invalid field name: ORANGE")
          lambda { (ExampleProject::WackyEnum.new(:NEGATIVE) <=> ExampleProject::Color.new(:RED)) }.should raise_error("Invalid Type: was ExampleProject::Color, expected ExampleProject::WackyEnum")
        end
      end 
    end
    # describe CauterizeFixedArray do
    #   convert to string
    #   new to_ruby
    #   pack unpack
    #   .each
    #   enumerable?
    #   only accepts the specified length
    #   .to_string
    #   can nest other types?
    #     scalar
    #     enum
    #     composite
    #     fixedarray
    #     vararray
    #     group
        
    # end

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
