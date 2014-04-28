describe Cauterize::Builders::CS::FixedArray do

  context "array class definition" do
    let(:fixed_arr) do
      Cauterize.scalar(:uint32_t) {|t| t.type_name(:uint32)}
      _fa = Cauterize.fixed_array(:myriad_data) do |a|
        a.array_type :uint32_t
        a.array_size 16
      end

      Cauterize::Builders.get(:cs, _fa)
    end

    describe ".class_defn" do
      let(:text) do
        f = four_space_formatter
        fixed_arr.class_defn(f)
        text = f.to_s
      end
      it "defines a class for the array" do
        text.should match /public class MyriadData : CauterizeFixedArrayTyped<UInt32>/
      end

      it "sets the size of the array from configuration" do
        text.should match /public MyriadData\(\)/ # no args
        text.should match /Allocate\(16\);/
      end

      it "allows defaulting an array" do
        text.should match /public MyriadData\(UInt32\[\] data\)/
        text.should match /Allocate\(data\);/
      end

      it "defines a size" do
        text.should match /public static int MySize = 16;/
        text.should match /protected override int Size/
        text.should match /get { return MySize; }/
      end
    end
  end
end
