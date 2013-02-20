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
        text.should match /public class MyriadData : CauterizeVariableArray/
      end

      it "defines the size type" do
        text.should match /public static Type SizeType = typeof\(Byte\);/
      end

      it "defines an array of the correct type" do
        text.should match /private UInt32\[\] _data;/
      end

      it "defines indexing into the array" do
        text.should match /public UInt32 this\[int i\]/
        text.should match /get { return _data\[i\]; }/
        text.should match /set { _data\[i\] = value; }/
      end

      it "defines slicing into the array" do
        text.should match /public UInt32\[\] this\[Tuple<int, int> range\]/
        text.should match /get { return _data.Skip\(range.Item1\).Take\(range.Item2-range.Item1\).ToArray\(\); }/
        text.should match /set { Array.ConstrainedCopy\(value, 0, _data, range.Item1, range.Item2 - range.Item1\); }/
      end

      it "sets the size of the array from configuration" do
        text.should match /public MyriadData\(int size\)/ # no args
        text.should match /_data = new UInt32\[size\];/
      end
    end
  end
end
