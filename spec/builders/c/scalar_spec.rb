module Cauterize
  describe Cauterize::Builders::C::Scalar do
    let(:type_constructor) {
      lambda {
        |name| Cauterize.scalar(name) {
          |t| t.type_name(:int32)
        }
      }
    }

    describe ".typedef_decl" do
      it "declares the type synonym" do
        s = Cauterize.scalar(:zeep) {|t| t.type_name(:int32)}

        f = default_formatter
        Builders.get(:c, s).typedef_decl(f)
        f.to_s.should == "typedef int32_t zeep;"
      end
    end

    it_behaves_like "a buildable"
    it_behaves_like "a sane buildable"
    include_examples "no enum"
    include_examples "no struct"
  end
end
