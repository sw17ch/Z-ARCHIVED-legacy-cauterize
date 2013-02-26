module Cauterize
  describe Cauterize::Builders::CS::Group do
    context "enumeration for type tag" do
      before do
        Cauterize.scalar(:uint8_t) {|t| t.type_name(:uint8)}
        @g = Cauterize.group!(:some_name) do |_g|
          _g.field(:a, :uint8_t)
          _g.field(:b, :uint8_t)
          _g.field(:c)
          _g.field(:d, :uint8_t)
        end
        @b = Cauterize::Builders::CS::Group.new(@g)
      end

      describe ".initialize" do
        it "creates the enumeration tag" do
          @b.instance_variable_get(:@tag_enum).class.name.should == "Cauterize::Enumeration"
        end
      end

      describe "@tag_enum" do
        it "contains a entry for each field in the group" do
          e = @b.instance_variable_get(:@tag_enum)
          e.values.keys.should =~ [ :GROUP_SOME_NAME_TYPE_A,
                                    :GROUP_SOME_NAME_TYPE_B,
                                    :GROUP_SOME_NAME_TYPE_C,
                                    :GROUP_SOME_NAME_TYPE_D ]
        end
      end

      describe ".class_defn" do
        it "defines an enum and class" do
          f = four_space_formatter
          @b.class_defn(f)
          fs = f.to_s

          fs.should == <<EOS
public class SomeName : CauterizeGroup
{
    [Order(0)]
    public GroupSomeNameType Type { get; set; }

    [Order(1)]
    public Byte A { get; set; }
    [Order(2)]
    public Byte B { get; set; }
    /* No data associated with 'c'. */
    [Order(4)]
    public Byte D { get; set; }
}
EOS
        end
      end
    end
  end
end
