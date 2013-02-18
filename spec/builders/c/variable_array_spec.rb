module Cauterize
  describe Cauterize::Builders::C::VariableArray do
    let(:type_constructor) do
      lambda do |name|
        Cauterize.variable_array(name) do |a|
          a.array_type(:uint8)
          a.array_size(8)
          a.size_type(:uint8)
        end
      end
    end

    it_behaves_like "a buildable"
    it_behaves_like "a sane buildable"
    include_examples "no enum"

    context "structure definition" do
      let(:vara) do
        _a = Cauterize.variable_array(:va) do |a|
          a.array_size(8)
          a.array_type(:int32)
          a.size_type(:int32)
        end

        Builders.get(:c, _a)
      end

      describe ".struct_proto" do
        it "defines a structure prototype" do
          f = default_formatter
          vara.struct_proto(f)
          f.to_s.should == "struct va;"
        end
      end

      describe ".struct_defn" do
        it "defines a structure definition" do
          f = default_formatter
          vara.struct_defn(f)
          fs = f.to_s

          fs.should match /struct va/
          fs.should match /int32_t length;/
          fs.should match /int32_t data\[8\];/
          fs.should match /};/
        end
      end
    end
  end
end
