include Cauterize::Builders::C

shared_examples "a sane buildable" do
  let(:desc_instance) { type_constructor.call(:some_type_name) }
  let(:formatter) { default_formatter }
  subject { described_class.new(desc_instance) }

  describe :render do
    it "contains the name" do
      subject.render.should match /some_type_name/
    end
  end

  describe :declare do
    before { subject.declare(formatter, :some_sym) }

    it "contains the name and a ;" do
      formatter.to_s.should match /some_type_name/
      formatter.to_s.should match /;/
    end
  end
end
