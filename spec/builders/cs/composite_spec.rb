module Cauterize
  describe Cauterize::Builders::CS::Composite do
    context "class definition" do
      let(:comp) do
        Cauterize.scalar(:int32_t) {|t| t.type_name(:int32) }
        Cauterize.scalar(:int16_t) {|t| t.type_name(:int16) }
        _c = Cauterize.composite(:foo) do |c|
          c.field(:an_int, :int32_t)
          c.field(:a_short, :int16_t)
        end

        Builders.get(:cs, _c)
      end

      describe ".class_defn" do
        it "defines a class for the composite" do
          f = four_space_formatter
          comp.class_defn(f)
          f.to_s.should == <<EOS
public class Foo : CauterizeComposite
{
    [Order(0)]
    public Int32 AnInt { get; set; }
    [Order(1)]
    public Int16 AShort { get; set; }
}
EOS
        end
      end
    end
  end
end
