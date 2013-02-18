module Cauterize
  describe Builders::C::BuiltIn do
    let(:bi) do
      b = BuiltIn.new(:foo)
      b.is_signed(false)
      b.byte_length(4)
      b
    end

    let (:bi_bldr) do
      Builders.get(:c, bi)
    end

    describe ".typedef_decl" do
      it "declares the type synonym" do
        f = default_formatter
        bi_bldr.typedef_decl(f)

        f.to_s.should == "typedef uint32_t foo;"
      end
    end

    describe ".declare" do
      it "declares a variable with the BuiltIn's type" do
        f = default_formatter
        bi_bldr.declare(f, :meep)
        f.to_s.should == "foo meep;"
      end
    end
  end
end
