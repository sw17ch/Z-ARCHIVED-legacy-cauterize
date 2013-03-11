describe Cauterize::Builders::CS::VariableArray do

  context "array class definition" do
    let(:var_arr) do
      Cauterize.scalar(:uint32_t) {|t| t.type_name(:uint32)}
      Cauterize.scalar(:uint8_t) {|t| t.type_name(:uint8)}
      _va = Cauterize.variable_array(:myriad_data) do |a|
        a.size_type :uint8_t
        a.array_type :uint32_t
        a.array_size 16
      end

      Cauterize::Builders.get(:cs, _va)
    end

    describe ".class_defn" do
      let(:text) do
        f = four_space_formatter
        var_arr.class_defn(f)
        text = f.to_s
      end
      it "defines a class for the array" do
        text.should match /public class MyriadData : CauterizeVariableArrayTyped<UInt32>/
      end

      it "defines the size type" do
        text.should match /public static Type SizeType = typeof\(Byte\);/
      end

      it "sets the size of the array from configuration" do
        text.should match /public MyriadData\(int size\)/ # no args
        text.should match /Allocate\(size\);/
      end

      it "allows defaulting an array" do
        text.should match /public MyriadData\(UInt32\[\] data\)/
        text.should match /Allocate\(data\);/
      end

      it "defines a max size" do
        text.should match /protected override int MaxSize/
        text.should match /get { return Byte\.MaxValue; }/
      end
    end
  end
end
