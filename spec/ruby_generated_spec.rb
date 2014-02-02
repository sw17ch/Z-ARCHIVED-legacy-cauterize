require 'tmpdir'
require 'fileutils'

def range_test_type(s)
  ("range_test_" + s.to_s)
end

def integer_builtin_type_ranges
  [ [:uint8,      0,  2**8-1,  1], 
    [:int8,   -2**7,  2**7-1,  1], 
    [:uint16,     0,  2**16-1, 2],
    [:int16,  -2**15, 2**15-1, 2],
    [:uint32,     0,  2**32-1, 4],
    [:int32,  -2**31, 2**31-1, 4],
    [:uint64,     0,  2**64-1, 8],
    [:int64,  -2**63, 2**63-1, 8],
  ]
end

def floating_builtin_type_ranges
  [ [:float32,  -3.4028234e38, 3.4028234e38, 4],
    [:float64,  Float::MIN, Float::MAX, 8],
  ]
end

def integer_builtin_types
  integer_builtin_type_ranges.each do |t, min_val, max_val, num_bytes|
    t_class = ExampleProject.const_get(range_test_type(t).camel.to_sym)
    yield t_class, min_val, max_val, num_bytes
  end
end

def floating_builtin_types
  floating_builtin_type_ranges.each do |t, min_val, max_val, num_bytes|
    t_class = ExampleProject.const_get(range_test_type(t).camel.to_sym)
    yield t_class, min_val, max_val, num_bytes
  end
end

def numeric_builtin_types
  integer_builtin_types do |t, min_val, max_val, num_bytes| 
    yield t, min_val, max_val, num_bytes
  end
  floating_builtin_types do |t, min_val, max_val, num_bytes|
    yield t, min_val, max_val, num_bytes
  end
end



Cauterize.set_name("example_project")
Cauterize.set_version("1.2.3")

integer_builtin_type_ranges.each do |builtin_type, min_val, max_val, num_bytes| 
  Cauterize.scalar(range_test_type(builtin_type).to_sym) do |t|
    t.type_name(builtin_type)
  end
end

floating_builtin_type_ranges.each do |builtin_type, min_val, max_val, num_bytes| 
  Cauterize.scalar(range_test_type(builtin_type).to_sym) do |t|
    t.type_name(builtin_type)
  end
end

Cauterize.scalar(:small_uint) {|t| t.type_name(:uint8)}

Cauterize.scalar(:a_test_bool) {|t| t.type_name(:bool)}
Cauterize.scalar(:a_test_float) {|t| t.type_name(:float32)}

Cauterize.fixed_array(:simple_integer_fixed_array) do |fa|
  fa.array_type :uint8
  fa.array_size 5
end

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
  g.dataless :void
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

  # puts File.read(@rb.rb)
end

# class FastName < CauterizeData
#   attr_reader :length
#   def initialize(raw_data)
#     @raw_data = raw_data.to_s
#     @length = ExampleProject::Name.size_type.construct(@raw_data.length)
#     raise "Invalid length: #{@raw_data.length}, max length is: #{ExampleProject::Name.max_length}" if @raw_data.length > ExampleProject::Name.max_length
#   end

#   def to_string
#     @raw_data
#   end

#   alias to_ruby to_string
#   alias pack to_string

#   def packio(x)
#     x << length.pack
#     x << @raw_data
#   end

#   def self.do_unpackio(x)
#     len = ExampleProject::Name.size_type.unpackio(x)
#     self.new(x.read(len.to_ruby))
#   end
# end

# ExampleProject::Name.set_specializer(FastName)

module Cauterize
  describe Cauterize::RubyBuilder do
    before(:all) do
      
    end

    after(:all) do
    end

    describe CauterizeRuby::Scalar do
      numeric_builtin_types do |c, min_val, max_val, num_bytes|
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
          it "pack should return .num_bytes bytes" do
            x = c.new(123)
            x.pack.length.should == x.num_bytes
            # and for builtins these should also be the same:
            x.pack.length.should == c::max_size
            x.pack.length.should == c::min_size
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
          it "num_bytes should match expected num_bytes" do
            c.new(max_val).num_bytes.should == num_bytes
            c::max_size.should == num_bytes
            c::min_size.should == num_bytes
          end
        end
      end

      integer_builtin_types do |c, min_val, max_val, num_byte|
        describe c do
          it "should not be able to store #{max_val + 1}" do
            lambda { c.new(max_val + 1)}.should raise_error("#{c}: Out of range value: #{max_val + 1}, for #{c}")
          end
          it "should not be able to store #{min_val - 1}" do
            lambda { c.new(min_val - 1)}.should raise_error("#{c}: Out of range value: #{min_val - 1}, for #{c}")
          end
          it "to_ruby and to_i and to_f should return the same number" do
            x = c.new(max_val) 
            x.to_i.should == x.to_ruby
            x.to_f.should be_within(0.0001).of(x.to_ruby)
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
            lambda { ExampleProject::ATestFloat.new(max_plus)}.should raise_error("ExampleProject::ATestFloat: Out of range value: #{max_plus}, for #{ExampleProject::ATestFloat}")
          end
          min_minus = -3.402824e38
          it "should not be able to store #{min_minus}" do
            lambda { ExampleProject::ATestFloat.new(min_minus)}.should raise_error("ExampleProject::ATestFloat: Out of range value: #{min_minus}, for #{ExampleProject::ATestFloat}")
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
        it "num_bytes == 1" do
          ExampleProject::ATestBool.new(true).pack.length.should == 1
          ExampleProject::ATestBool.new(true).num_bytes.should == 1
          ExampleProject::ATestBool::max_size.should == 1
          ExampleProject::ATestBool::min_size.should == 1
        end
      end
    end

    describe CauterizeRuby::Enumeration do
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
          it "should pack to .num_bytes bytes" do
            x = ExampleProject::Color.new(color)
            x.pack.length.should == x.num_bytes
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
            lambda { ExampleProject::Color.new(non_color)}.should raise_error("ExampleProject::Color: Invalid field name: #{non_color}, Valid field names are: [:RED, :BLUE, :GREEN]")
          end
        end
        it ".from_int should raise error on invalid input" do
          lambda { ExampleProject::Color.from_int(-1)}.should raise_error("ExampleProject::Color: Invalid enumeration value: -1")
          lambda { ExampleProject::Color.from_int(3)}.should raise_error("ExampleProject::Color: Invalid enumeration value: 3")
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
          it "should pack to .num_bytes bytes" do
            x = ExampleProject::WackyEnum.new(k)
            x.pack.length.should == x.num_bytes
          end
          it "max_size == min_size should be 2 for our wacky enum" do
            ExampleProject::WackyEnum::max_size.should == 2
            ExampleProject::WackyEnum::min_size.should == 2
          end
          it ".to_i should be the enum value" do
            ExampleProject::WackyEnum.new(k).to_i.should == v 
          end
          it ".from_int and .to_i should be inverses" do
            ExampleProject::WackyEnum.from_int(v).to_i.should == v
          end
        end
        it ".from_int should raise error on invalid input" do
          lambda { ExampleProject::WackyEnum.from_int(0)}.should raise_error("ExampleProject::WackyEnum: Invalid enumeration value: 0")
          lambda { ExampleProject::WackyEnum.from_int(-498)}.should raise_error("ExampleProject::WackyEnum: Invalid enumeration value: -498")
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
        describe "#==" do
          example_wacky.each do |k1, v1|
            example_wacky.each do |k2, v2|
              it "should be equal if enum values are equal" do
                if v1 == v2
                  (ExampleProject::WackyEnum.new(k1) == ExampleProject::WackyEnum.new(k2)).should be_true
                  (ExampleProject::WackyEnum.new(k1) != ExampleProject::WackyEnum.new(k2)).should be_false
                else
                  (ExampleProject::WackyEnum.new(k1) == ExampleProject::WackyEnum.new(k2)).should be_false
                  (ExampleProject::WackyEnum.new(k1) != ExampleProject::WackyEnum.new(k2)).should be_true
                end
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
          lambda { (ExampleProject::Color.new(:RED) <=> 0) }.should raise_error("ExampleProject::Color: Invalid field name: 0, Valid field names are: [:RED, :BLUE, :GREEN]")
          lambda { (ExampleProject::Color.new(:RED) <=> :ORANGE) }.should raise_error("ExampleProject::Color: Invalid field name: ORANGE, Valid field names are: [:RED, :BLUE, :GREEN]")
          lambda { (ExampleProject::WackyEnum.new(:NEGATIVE) <=> ExampleProject::Color.new(:RED)) }.should raise_error("Invalid Type: was ExampleProject::Color, expected ExampleProject::WackyEnum")
        end
      end
    end

    describe CauterizeRuby::VariableArray do
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

    describe CauterizeRuby::FixedArray do

      it ".new and .to_ruby are inverses" do
        test_array = [1, 2, 6, 10, 100, 0]
        ExampleProject::MacAddress.new(test_array).to_ruby.should == test_array
      end

      it "can pack, and unpack to its original value" do
        test_array = [1, 2, 6, 10, 100, 0]
        ExampleProject::MacAddress.unpack(ExampleProject::MacAddress.new(test_array).pack).to_ruby.should == test_array
      end

      it "should pack to .num_bytes bytes" do
        test_array = [1, 2, 6, 10, 100, 0]
        x = ExampleProject::MacAddress.new(test_array)
        x.pack.length.should == x.num_bytes
      end

      it "raises an exception if the array length is wrong" do
        lambda { ExampleProject::MacAddress.new([1, 2, 6, 10, 100]) }.should raise_error("ExampleProject::MacAddress: Invalid length: 5, expected: 6")
        lambda { ExampleProject::MacAddress.new([1, 2, 6, 10, 100, 1, 12]) }.should raise_error("ExampleProject::MacAddress: Invalid length: 7, expected: 6")
      end

      it "it has a valid enumerator interface" do
        test_array = [1, 2, 6, 10, 100, 0]
        x = ExampleProject::MacAddress.new(test_array)
        x.to_enum.to_a.should == test_array
        x.min.should == 0
        x.max.should == 100
        x.sort.should == test_array.sort
      end

      it "can be converted to a string if elements are in the right range" do
        test_array = "foobar".bytes
        ExampleProject::MacAddress.new(test_array).to_string.should == "foobar"
        ExampleProject::MacAddress.new("asdfas").to_string.should == "asdfas"
      end

      describe "#==" do
        it "should return true for equal arrays" do
          (ExampleProject::MacAddress.new([1, 2, 6, 10, 100, 0]) == [1, 2, 6, 10, 100, 0]).should be_true
          (ExampleProject::MacAddress.new([1, 2, 6, 10, 100, 0]) == ExampleProject::MacAddress.new([1, 2, 6, 10, 100, 0])).should be_true
          (ExampleProject::MacAddress.new([1, 2, 6, 10, 100, 0]) != ExampleProject::MacAddress.new([1, 2, 6, 10, 100, 0])).should be_false
        end
        it "should return false for non-equal arrays" do
          (ExampleProject::MacAddress.new([1, 2, 10, 100, 5, 0]) == ExampleProject::MacAddress.new([1, 2, 6, 10, 100, 0])).should be_false
          (ExampleProject::MacAddress.new([1, 2, 10, 100, 5, 0]) != ExampleProject::MacAddress.new([1, 2, 6, 10, 100, 0])).should be_true
        end
      end

      # describe "#num_bytes" do
      #   it "should match "
      # end

      it "num_bytes == max_size == min_size but _just for this particular fixed array_" do
        test_array = [1, 2, 6, 10, 100, 0]
        ExampleProject::MacAddress.new(test_array).num_bytes.should == 6
        ExampleProject::MacAddress::max_size.should == 6
        ExampleProject::MacAddress::min_size.should == 6
      end
      
      describe "#<=>" do
        sample_arrays = [[0, 0, 0, 0, 1, 2], 
                         [0, 1, 0, 0, 0, 0],
                         [0, 1, 0, 1, 0, 0]]
        sample_arrays.each_with_index do |arr_a, i|
          sample_arrays.each_with_index do |arr_b, j|
            it "should give a lexicographical ordering" do
              (ExampleProject::MacAddress.new(arr_a) <=> ExampleProject::MacAddress.new(arr_b)).should == (i <=> j)
            end
          end
        end
      end
    end

    describe CauterizeRuby::VariableArray do

      test_arrays = ["Job Vranish".bytes.to_a,
                     [] ]
      test_arrays.each do |test_array|
        it ".new and .to_ruby are inverses" do
          ExampleProject::Name.new(test_array).to_ruby.should == test_array
        end

        it "can pack, and unpack to its original value" do
          ExampleProject::Name.unpack(ExampleProject::Name.new(test_array).pack).to_ruby.should == test_array
        end

        it "should pack to .num_bytes bytes" do
          x = ExampleProject::Name.new(test_array)
          x.pack.length.should == x.num_bytes
        end
      end

      it "raises an exception if the array it too long" do
        lambda { ExampleProject::Name.new([1] * 33) }.should raise_error("ExampleProject::Name: Invalid length: 33, max length is: 32")
      end

      it "it has a valid enumerator interface" do
        test_array = [1, 2, 6, 10, 100, 0]
        x = ExampleProject::Name.new(test_array)
        x.to_enum.to_a.should == test_array
        x.min.should == 0
        x.max.should == 100
        x.sort.should == test_array.sort
      end

      it "can be converted to a string if elements are in the right range" do
        test_array = "Job Vranish".bytes
        ExampleProject::Name.new(test_array).to_string.should == "Job Vranish"
        ExampleProject::Name.new("asdfas").to_string.should == "asdfas"
        ExampleProject::Name.new("").to_string.should == ""
      end

      it "min size is just the size of the size type, max size is max size of all elements" do
        c = ExampleProject::Name
        test_array = [1, 2, 6, 10, 100, 0]
        c.new(test_array).num_bytes.should == 7
        c::max_size.should == c::size_type::max_size + (c::elem_type::max_size * c::max_length)
        c::min_size.should == c::size_type::min_size
      end

      describe "#==" do
        it "should return true for equal arrays" do
          (ExampleProject::Name.new([1, 2, 6, 10, 100, 0]) == [1, 2, 6, 10, 100, 0]).should be_true
          (ExampleProject::Name.new([1, 2, 6, 10, 100, 0]) == ExampleProject::Name.new([1, 2, 6, 10, 100, 0])).should be_true
          (ExampleProject::Name.new([1, 2, 6, 10, 100, 0]) != ExampleProject::Name.new([1, 2, 6, 10, 100, 0])).should be_false
        end
        it "should return false for non-equal arrays" do
          (ExampleProject::Name.new([1, 2, 10, 100, 0]) == ExampleProject::Name.new([1, 2, 6, 10, 100, 0])).should be_false
          (ExampleProject::Name.new([1, 2, 10, 100, 0]) != ExampleProject::Name.new([1, 2, 6, 10, 100, 0])).should be_true
        end
      end
      
      describe "#<=>" do
        sample_arrays = [[0, 1, 2], 
                         [0, 2, 2],
                         [1, 0, 0]]
        sample_arrays.each_with_index do |arr_a, i|
          sample_arrays.each_with_index do |arr_b, j|
            it "should give a lexicographical ordering" do
              (ExampleProject::Name.new(arr_a) <=> ExampleProject::Name.new(arr_b)).should == (i <=> j)
            end
          end
        end
      end

    end

    describe CauterizeRuby::Composite do
      sample_persons = [ { first_name: "Jane", last_name: "Smith", gender: :MALE },
                         { first_name: "Jill", last_name: "Smith", gender: :FEMALE},
                         { first_name: "John", last_name: "Smit",  gender: :MALE },
                         { first_name: "John", last_name: "Smith", gender: :MALE }]

      sample_persons.each do |p|
        it ".new and .to_ruby are inverses" do
          ExampleProject::Person.new(p).should == p
        end
        it "can pack, and unpack to its original value" do
          ExampleProject::Person.unpack((ExampleProject::Person.new(p).pack)).should == p
        end
        it "pack should pack to .num_bytes bytes" do
          x = ExampleProject::Person.new(p)
          x.pack.length.should == x.num_bytes
        end
      end

      it "should raise an error if fields are missing during initialization" do
        lambda { ExampleProject::Person.new({ last_name: "Smith", gender: :MALE }) }.should raise_error("ExampleProject::Person: Invalid initialization params, missing fields: [:first_name], extra fields: []")
      end

      it "should raise an error if there are extra fields during initialization" do
        lambda { ExampleProject::Person.new({ first_name: "Jane", last_name: "Smith", age: 12, gender: :MALE }) }.should raise_error("ExampleProject::Person: Invalid initialization params, missing fields: [], extra fields: [:age]")
      end

      describe "#max_size" do
        it "should be the sum of the max sizes of the fields" do
          c = ExampleProject::Person
          c::max_size.should == c::fields.values.reduce(0) {|sum, v| sum + v::max_size}
        end
      end
      describe "#min_size" do
        it "should be the sum of the min sizes of the fields" do
          c = ExampleProject::Person
          c::min_size.should == c::fields.values.reduce(0) {|sum, v| sum + v::min_size}
        end
      end

      it "should have accessors for all the fields" do
        test_person = ExampleProject::Person.new({ first_name: "test", last_name: "thing", gender: :MALE})
        test_person.first_name.should == "test"
        test_person.last_name.should == "thing"
        test_person.gender.should == :MALE
      end
      
      describe "#<=>" do
        sample_persons.each_with_index do |p1, i|
          sample_persons.each_with_index do |p2, j|
            it "should give a lexicographical ordering" do
              (ExampleProject::Person.new(p1) <=> p2).should == (i <=> j)
              (ExampleProject::Person.new(p1) <=> ExampleProject::Person.new(p2)).should == (i <=> j)
            end
          end
        end
      end

      describe "#==" do
        sample_persons.each_with_index do |p1, i|
          sample_persons.each_with_index do |p2, j|
            it "should return true for equal things, false otherwise" do
              (ExampleProject::Person.new(p1) == p2).should == (i == j)
              (ExampleProject::Person.new(p1) == ExampleProject::Person.new(p2)).should == (i == j)
              (ExampleProject::Person.new(p1) != p2).should == (i != j)
              (ExampleProject::Person.new(p1) != ExampleProject::Person.new(p2)).should == (i != j)
            end
          end
        end
      end
    end

    describe CauterizeRuby::Group do
      test_groups = [ { tag: :PERSON, data: { first_name: "Jane", last_name: "Smith", gender: :MALE }},
                      { tag: :DOG, data: { name: "Fido", leg_count: 3, gender: :MALE }}]

      test_groups.each do |g|
        it ".new and .to_ruby are inverses" do
          ExampleProject::Creature.new(g).should == g
        end
        it "can pack, and unpack to its original value" do
          ExampleProject::Creature.unpack((ExampleProject::Creature.new(g).pack)).should == g
        end
        it "pack should pack to .num_bytes bytes" do
          x = ExampleProject::Creature.new(g)
          x.pack.length.should == x.num_bytes
        end
      end

      describe "#max_size" do
        it "should be the max size of the tag + max of the max sizes of the fields" do
          c = ExampleProject::Creature
          c::max_size.should == c::tag_type::max_size + c::fields.values.map{|v| (v.nil?) ? 0 : v::max_size}.max
        end
      end

      describe "#min_size" do
        it "should be the max size of the tag + min of the min sizes of the fields" do
          c = ExampleProject::Creature
          c::min_size.should == c::tag_type::min_size + c::fields.values.map{|v| (v.nil?) ? 0 : v::min_size}.min
        end
      end

      describe "#<=>" do
        test_groups.each_with_index do |a, i|
          test_groups.each_with_index do |b, j|
            it "should give a lexicographical ordering" do
              (ExampleProject::Creature.new(a) <=> b).should == (i <=> j)
              (ExampleProject::Creature.new(a) <=> ExampleProject::Creature.new(b)).should == (i <=> j)
            end
          end
        end
      end

      describe "#==" do
        test_groups.each_with_index do |a, i|
          test_groups.each_with_index do |b, j|
            it "should return true for equal things, false otherwise" do
              (ExampleProject::Creature.new(a) == b).should == (i == j)
              (ExampleProject::Creature.new(a) == ExampleProject::Creature.new(b)).should == (i == j)
              (ExampleProject::Creature.new(a) != b).should == (i != j)
              (ExampleProject::Creature.new(a) != ExampleProject::Creature.new(b)).should == (i != j)
            end
          end
        end
      end
    end
  end
end
