module Cauterize
  describe Builders::C::BuiltIn do
    let(:bi) do
      b = BuiltIn.new(:foo)
      b.flavor(:unsigned)
      b.byte_length(4)
      b
    end

    let (:bi_bldr) do
      Builders.get(:c, bi)
    end

    describe ".declare" do
      it "declares a variable with the BuiltIn's type" do
        f = default_formatter
        bi_bldr.declare(f, :meep)
        f.to_s.should == "uint32_t meep;"
      end
    end
  end
end
