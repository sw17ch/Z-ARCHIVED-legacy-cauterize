require 'tmpdir'
require 'fileutils'

describe Cauterize do
  before do
    reset_for_test
  end

  describe CBuilder do
    before do
      @tempdir = Dir.mktmpdir
      @h_path = File.join(@tempdir, "testing.h")
      @c_path = File.join(@tempdir, "testing.c")

      @cb = CBuilder.new(@h_path, @c_path, "testing")
    end
    after { FileUtils.rm_rf @tempdir }

    describe :initialize do
      it "saves the h and c paths" do
        @cb.h.should == @h_path
        @cb.c.should == @c_path
      end
    end

    describe :build do
      before do
        atom(:uint8_t)
        atom(:uint16_t)
        atom(:uint32_t)

        fixed_array(:mac_address) do |fa|
          fa.array_type :uint8_t
          fa.array_size 6
        end

        variable_array(:mac_table) do |t|
          t.array_type :mac_address
          t.array_size 64
          t.size_type :uint8_t
        end

        variable_array(:name) do |va|
          va.array_type :uint8_t
          va.size_type :uint8_t
          va.array_size 32
        end

        enumeration(:gender) do |e|
          e.value :male
          e.value :female
        end

        composite(:place) do |c|
          c.field :name, :name
          c.field :elevation, :uint32_t
        end

        composite(:person) do |c|
          c.field :first_name, :name
          c.field :last_name, :name
          c.field :gender, :gender
        end

        composite(:dog) do |c|
          c.field :name, :name
          c.field :gender, :gender
          c.field :leg_count, :uint8_t
        end

        group(:animal) do |g|
          g.field :person, :person
          g.field :dog, :dog
        end

        @cb.build
        @h_text = File.read(@cb.h)
        @h_lines = @h_text.lines.to_a
        @c_text = File.read(@cb.c)
        @c_lines = @c_text.lines.to_a
      end

      describe "header generation" do
        it "prevents multiple inclusion in headers" do
          @h_lines[0].should match /#ifndef TESTING_H/
          @h_lines[1].should match /#define TESTING_H/
          @h_lines.last.should match /#endif \/\* TESTING_H \*\//
        end

        it "includes prototype information for all defined types" do
          @h_text.should match "struct name;"
          @h_text.should match "struct person;"
          @h_text.should match "struct place;"
        end

        it "includes enumeration and structure definitions" do
          @h_text.should match /gender/
          @h_text.should match /MALE = 0/
          @h_text.should match /FEMALE = 1/
        end
      end

      describe "c body generation" do
        it "includes the generated header file" do
          @c_text.should match /#include "testing.h"/
        end
      end

      describe "compilation" do
        it "can be built" do
          caut_dir = "#{File.dirname(__FILE__)}/../c/src"

          res = Dir.chdir @tempdir do
            File.open("test_main.c", "wb") do |fh|
              syms = BaseType.all_instances.map{|i| [i.pack_sym, i.unpack_sym]}.flatten
              fh.write(gen_test_main(syms))
            end

            cmd = %W{
              clang -Wall -Wextra -Werror
              -I#{caut_dir}
              #{@cb.c}
              #{caut_dir}/cauterize.c
              test_main.c
              -o testing.bin 2>&1
            }.join(" ")

            `#{cmd}`
          end

          res.should == ""
        end
      end
    end
  end
end
