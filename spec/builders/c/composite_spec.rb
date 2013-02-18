module Cauterize
  describe Cauterize::Builders::C::Composite do
    before do
      Cauterize.scalar(:my_int) {|t| t.type_name(:int32)}
    end

    let(:type_constructor) do
      lambda do |name|
        Cauterize.composite(name) do |c|
          c.field :an_int, :my_int
          c.field :another_int, :my_int
        end
      end
    end

    it_behaves_like "a buildable"
    it_behaves_like "a sane buildable"
    include_examples "no enum"

    context "structure definition" do
      let(:comp) do
        _c = Cauterize.composite(:foo) do |c|
          c.field(:an_int, :my_int)
        end

        Builders.get(:c, _c)
      end

      describe ".struct_proto" do
        it "defines a structure prototype" do
          f = default_formatter
          comp.struct_proto(f)
          f.to_s.should == "struct foo;"
        end
      end

      describe ".struct_defn" do
        it "defines a structure definition" do
          f = default_formatter
          comp.struct_defn(f)
          fs = f.to_s

          fs.should match /struct foo/
          fs.should match /my_int an_int;/
          fs.should match /};/
        end
      end
    end
  end
end
