# shared examples for stubbed functions

include Cauterize::Builders::C

shared_examples "no struct" do
  let(:desc_instance) { type_constructor.call(:some_type_name) }
  let(:builder) { Cauterize::Builders.get(:c, desc_instance) }

  it {  builder.struct_proto(:f).should be_nil }
  it {  builder.struct_defn(:f).should be_nil }
end

shared_examples "no enum" do
  let(:desc_instance) { type_constructor.call(:some_type_name) }
  let(:builder) { Cauterize::Builders.get(:c, desc_instance) }

  it {  builder.enum_defn(:f).should be_nil }
end
