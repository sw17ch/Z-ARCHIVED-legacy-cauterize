module Cauterize
  describe Cauterize::Builders::CS::Composite do
    context "class definition" do
      let(:comp) do
        Cauterize.scalar(:int32_t)
        _c = Cauterize.composite(:foo) do |c|
          c.field(:an_int, :int32_t)
        end

        Builders.get(:cs, _c)
      end

      describe ".class_defn" do
        it "defines a class for the composite" do
          f = four_space_formatter
          comp.class_defn(f)
          f.to_s.should == <<EOS
public class Foo
{
    public Int32 AnInt { get; set; }
}
EOS
        end
      end
    end
  end
end
