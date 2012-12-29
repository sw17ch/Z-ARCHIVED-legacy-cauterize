describe Cauterize::Builders::C::Composite do
  let(:type_constructor) do
    lambda do |name|
      scalar(:int32)
      composite(name) do |c|
        c.field :an_int, :int32
        c.field :another_int, :int32
      end
    end
  end

  it_behaves_like "a buildable"
  it_behaves_like "a sane buildable"
  include_examples "no enum"

  context "structure definition" do
    let(:comp) do
      scalar(:int32)
      _c = composite(:foo) do |c|
        c.field(:an_int, :int32)
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
        fs.should match /int32 an_int;/
        fs.should match /};/
      end
    end
  end
end
