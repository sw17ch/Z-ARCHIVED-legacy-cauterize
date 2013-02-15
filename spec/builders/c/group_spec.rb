module Cauterize
  describe Cauterize::Builders::C::Group do
    let(:type_constructor) { lambda {|name| Cauterize.group(name)}}

    it_behaves_like "a buildable"
    it_behaves_like "a sane buildable"
    include_examples "no enum"

    context "enumeration for type tag" do
      before do
        Cauterize.scalar(:uint8_t)
        @g = Cauterize.group!(:some_name) do |_g|
          _g.field(:a, :uint8_t)
          _g.field(:b, :uint8_t)
          _g.field(:c)
        end
        @b = Cauterize::Builders::C::Group.new(@g)
      end

      describe ".initialize" do
        it "creates the enumeration tag" do
          @b.instance_variable_get(:@tag_enum).class.name.should == "Cauterize::Enumeration"
        end
      end

      describe "@tag_enum" do
        it "contains a entry for each field in the group" do
          e = @b.instance_variable_get(:@tag_enum)
          e.values.keys.should =~ [ :GROUP_SOME_NAME_TYPE_A,
                                    :GROUP_SOME_NAME_TYPE_B,
                                    :GROUP_SOME_NAME_TYPE_C ]
        end
      end

      describe ".packer_defn" do
        before do
          f = default_formatter
          @b.packer_defn(f)
          @fs = f.to_s
        end

        it "contains the enum packer" do
          @fs.should match /Pack_group_some_name_type/
        end

        it "contains each tag" do
          @fs.should match /GROUP_SOME_NAME_TYPE_A/
          @fs.should match /GROUP_SOME_NAME_TYPE_B/
          @fs.should match /GROUP_SOME_NAME_TYPE_C/
        end

        it "contains each data field" do
          @fs.should match /src->data\.a/
          @fs.should match /src->data\.b/
        end
      end

      describe ".unpacker_defn" do
        before do
          f = default_formatter
          @b.unpacker_defn(f)
          @fs = f.to_s
        end

        it "contains the enum unpacker" do
          @fs.should match /Unpack_group_some_name_type/
        end

        it "contains each tag" do
          @fs.should match /GROUP_SOME_NAME_TYPE_A/
          @fs.should match /GROUP_SOME_NAME_TYPE_B/
          @fs.should match /GROUP_SOME_NAME_TYPE_C/
        end

        it "contains each data field" do
          @fs.should match /dst->data\.a/
          @fs.should match /dst->data\.b/
        end
      end
    end

    context "structure definition" do
      let(:grp) do
        Cauterize.scalar(:int32)
        _g = Cauterize.group(:oof) do |g|
          g.field(:aaa, :int32)
          g.field(:bbb, :int32)
          g.field(:empty)
        end

        Builders.get(:c, _g)
      end

      describe ".struct_proto" do
        it "defines a structure prototype" do
          f = default_formatter
          grp.struct_proto(f)
          f.to_s.should == "struct oof;"
        end
      end

      describe ".struct_defn" do
        it "defines a structure definition" do
          f = default_formatter
          grp.struct_defn(f)
          fs = f.to_s

          fs.should match /struct oof/
          fs.should match /enum group_oof_type tag;/
          fs.should match /union/
          fs.should match /int32 aaa;/
          fs.should match /int32 bbb;/
          fs.should match /No data associated with 'empty'./
          fs.should match /} data;/
          fs.should match /};/
        end
      end
    end
  end
end
