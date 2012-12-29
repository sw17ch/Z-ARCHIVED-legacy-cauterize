describe Cauterize::Builders::C::FixedArray do
  let(:type_constructor) do
    scalar(:uint32_t)
    lambda do |name|
      fixed_array(name) do |a|
        a.array_type :uint32_t
        a.array_size 16
      end
    end
  end

  it_behaves_like "a buildable"
  include_examples "no enum"
  include_examples "no struct"

  context "an array buildable" do
    let(:desc_instance) { type_constructor.call(:some_type_name) }
    let(:formatter) { default_formatter }
    subject { described_class.new(desc_instance) }

    describe :render do
      it "contains the name" do
        t_name = subject.instance_variable_get(:@blueprint).array_type.name
        subject.render.should match /#{t_name}/
      end
    end

    describe :declare do
      before { subject.declare(formatter, :some_sym) }

      it "contains the name and a ;" do
        formatter.to_s.should match /uint32_t some_sym\[16\]; \/\* some_type_name \*\//
      end
    end
  end
end
