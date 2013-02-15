module Cauterize
  describe Cauterize::Builders::C::Scalar do
    let(:type_constructor) { lambda {|name| Cauterize.scalar(name)}}

    it_behaves_like "a buildable"
    it_behaves_like "a sane buildable"
    include_examples "no enum"
    include_examples "no struct"
  end
end
