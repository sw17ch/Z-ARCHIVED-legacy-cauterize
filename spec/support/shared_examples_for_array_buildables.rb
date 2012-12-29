include Cauterize::Builders::C

shared_examples "an array buildable" do
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
