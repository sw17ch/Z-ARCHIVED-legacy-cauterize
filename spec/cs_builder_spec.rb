require 'tmpdir'
require 'fileutils'

module Cauterize
  describe Cauterize::CSBuilder do
    before do
      @tempdir = Dir.mktmpdir
      @cs_path = File.join(@tempdir, "testing.cs")
      @csb = CSBuilder.new(@cs_path, "testing")
    end
    
    after do
      FileUtils.rm_rf @tempdir 
    end

    describe :build do
      before do
        Cauterize.set_version("1.2.3")

        Cauterize.scalar(:uint8_t) { |t| t.type_name(:uint8) }
        Cauterize.scalar(:uint16_t) { |t| t.type_name(:uint16) }
        Cauterize.scalar(:uint32_t) { |t| t.type_name(:uint32) }

        Cauterize.fixed_array(:mac_address) do |fa|
          fa.array_type :uint8_t
          fa.array_size 6
        end

        Cauterize.variable_array(:mac_table) do |t|
          t.array_type :mac_address
          t.array_size 64
          t.size_type :uint8_t
        end

        Cauterize.variable_array(:name) do |va|
          va.array_type :uint8_t
          va.size_type :uint8_t
          va.array_size 32
        end

        Cauterize.enumeration(:gender) do |e|
          e.value :male
          e.value :female
        end

        Cauterize.composite(:place) do |c|
          c.field :name, :name
          c.field :elevation, :uint32_t
        end

        Cauterize.composite(:person) do |c|
          c.field :first_name, :name
          c.field :last_name, :name
          c.field :gender, :gender
        end

        Cauterize.composite(:dog) do |c|
          c.field :name, :name
          c.field :gender, :gender
          c.field :leg_count, :uint8_t
        end

        Cauterize.group(:creature) do |g|
          g.field :person, :person
          g.field :dog, :dog
        end

        @csb.build
        @cs_text = File.read(@csb.cs)
        @cs_lines = @cs_text.lines.to_a
      end

      it "includes namespaces" do
        @cs_lines.should include("using System;\n")
        @cs_lines.should include("using System.Linq;\n")
        @cs_lines.should include("using Cauterize;\n")
      end

      it "uses a namespace" do
        @cs_lines.should include("namespace Testing\n")
      end

      it "creates a cauterize info class with version and date" do
        @cs_text.should match /Name = \"Testing\";/
        @cs_text.should match /GeneratedVersion = \"1.2.3\";/
        @cs_text.should match /GeneratedDate = /
      end

      it "includes enumeration definitions" do
        @cs_text.should match /public enum Gender/
        @cs_text.should match /Male = 0/
        @cs_text.should match /Female = 1/
      end

      # it "can be built" do 
      #   caut_dir = "#{File.dirname(__FILE__)}/../cs/src"

      #   res = Dir.chdir @tempdir do
      #     File.open("test_main.cs", "wb") do |fh|
      #       syms = BaseType.all_instances.map do |i|
      #         b = Builders.get(:cs, i)
      #         [b.packer_sym, b.unpacker_sym]
      #       end.flatten
      #       fh.write(gen_test_main(syms))
      #     end

      #     `dmcs -lib:#{caut_dir} -target:library test_main.cs 2>&1`
      #   end

      #   res.should == ""
      # end
    end
  end
end
