require 'tmpdir'
require 'fileutils'

module Cauterize
  describe Cauterize::DocBuilder do
    before do
      @tempdir = Dir.mktmpdir
      @doc_path = File.join(@tempdir, "testing.txt")

      @db = DocBuilder.new(@doc_path, "testing")
    end

    after do
      FileUtils.rm_rf @tempdir
    end

    describe :initialize do
      it "should save the name" do
        @db.name.should == "testing"
        @db.doc_path.should == @doc_path
      end
    end

    describe :build do
      before do
        Cauterize.set_version("1.2.3")

        Cauterize.scalar(:an_int, "a useful int") {|t| t.type_name :int32}
        Cauterize.scalar(:another_int) {|t| t.type_name :int32}

        Cauterize.composite(:a_composite, "some useful fields") do |t|
          t.field :an_int, :int32, "a pretty integer"
          t.field :another_int, :int32, "another pretty integer"
          t.field :undescribed, :int32
        end

        Cauterize.composite(:mystery) do |t|
          t.field :undescribed, :int32
        end

        Cauterize.fixed_array(:a_fixed_array, "a few things") do |t|
          t.array_type :an_int
          t.array_size 5
        end

        Cauterize.fixed_array(:a_mystery_array) do |t|
          t.array_type :uint8
          t.array_size 1
        end

        Cauterize.variable_array(:a_var_array, "maybe some things") do |t|
          t.array_type :an_int
          t.array_size 5
          t.size_type :uint8
        end

        Cauterize.variable_array(:a_var_mystery) do |t|
          t.array_type :uint8
          t.array_size 1
          t.size_type :uint8
        end

        Cauterize.enumeration(:some_colors, "several colors to choose from") do |t|
          t.value :red
          t.value :blue
          t.value :green
        end

        Cauterize.enumeration(:mystery_things) do |t|
          t.value :thing1
          t.value :thing2
          t.value :thing3
        end

        Cauterize.group(:oddness, "a mix of weird things") do |t|
          t.field :a_color, :some_colors, "a color"
          t.field :a_cool_int, :int16, "only cool ints fit here"
          t.dataless :a_thing, "only a thing"
          t.dataless :undescribed
        end

        Cauterize.group(:mystery_oddness) do |t|
          t.field :a_color, :some_colors
          t.field :a_cool_int, :int16
          t.dataless :a_thing, "only a thing"
          t.dataless :undescribed
        end

        @db.build
        @doc_text = File.read(@doc_path)
        @doc_lines = @doc_text.lines.to_a
      end

      describe "doc generation" do
        it "contains type details" do
          t = <<EOF
builtin int8
builtin int16
builtin int32
builtin int64
builtin uint8
builtin uint16
builtin uint32
builtin uint64
scalar an_int - int32 - a useful int
scalar another_int - int32
composite a_composite - some useful fields
  an_int - int32 - a pretty integer
  another_int - int32 - another pretty integer
  undescribed - int32
composite mystery
  undescribed - int32
fixed_array a_fixed_array - a few things
  data: 5 values of type an_int
fixed_array a_mystery_array
  data: 1 values of type uint8
variable_array a_var_array - maybe some things
  length: length of data is encoded as type uint8
  data: up to 5 values of type an_int
variable_array a_var_mystery
  length: length of data is encoded as type uint8
  data: up to 1 values of type uint8
enumeration some_colors - several colors to choose from
  encoded as type int8
  values:
    red = 0
    blue = 1
    green = 2
enumeration mystery_things
  encoded as type int8
  values:
    thing1 = 0
    thing2 = 1
    thing3 = 2
group oddness - a mix of weird things
  representation encoded as enumeration group_oddness_type
  representations:
    a_color - some_colors - a color
    a_cool_int - int16 - only cool ints fit here
    a_thing - <none> - only a thing
    undescribed - <none>
enumeration group_oddness_type
  encoded as type int8
  values:
    GROUP_ODDNESS_TYPE_A_COLOR = 0
    GROUP_ODDNESS_TYPE_A_COOL_INT = 1
    GROUP_ODDNESS_TYPE_A_THING = 2
    GROUP_ODDNESS_TYPE_UNDESCRIBED = 3
group mystery_oddness
  representation encoded as enumeration group_mystery_oddness_type
  representations:
    a_color - some_colors
    a_cool_int - int16
    a_thing - <none> - only a thing
    undescribed - <none>
enumeration group_mystery_oddness_type
  encoded as type int8
  values:
    GROUP_MYSTERY_ODDNESS_TYPE_A_COLOR = 0
    GROUP_MYSTERY_ODDNESS_TYPE_A_COOL_INT = 1
    GROUP_MYSTERY_ODDNESS_TYPE_A_THING = 2
    GROUP_MYSTERY_ODDNESS_TYPE_UNDESCRIBED = 3
EOF
          @doc_text.should == t.chomp
        end
      end
    end
  end

end
