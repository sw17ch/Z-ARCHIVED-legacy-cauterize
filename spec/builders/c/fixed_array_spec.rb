describe Cauterize::Builders::C::FixedArray do
  let(:type_constructor) do
    Cauterize.scalar(:uint32_t)
    lambda do |name|
      Cauterize.fixed_array(name) do |a|
        a.array_type :uint32_t
        a.array_size 16
      end
    end
  end

  it_behaves_like "a buildable"
  it_behaves_like "a sane buildable"
  include_examples "no enum"

  context "an array buildable" do
    let(:desc_instance) { type_constructor.call(:some_type_name) }
    let(:formatter) { default_formatter }
    subject { described_class.new(desc_instance) }

    describe :render do
      it "contains the name" do
        name = subject.instance_variable_get(:@blueprint).name
        subject.render.should match /#{name}/
      end
    end

    describe :declare do
      before { subject.declare(formatter, :some_sym) }

      it "contains the name and a ;" do
        formatter.to_s.should match /struct some_type_name some_sym;/
      end
    end
  end
end
