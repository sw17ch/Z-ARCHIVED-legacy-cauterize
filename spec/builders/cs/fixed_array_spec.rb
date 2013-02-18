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
        text.should match /public class MyriadData/
      end

      it "defines an array of the correct type" do
        text.should match /private UInt32\[\] _data;/
      end

      it "defines indexing into the array" do
        text.should match /public UInt32 this\[int i\]/
        text.should match /get { return _data\[i\]; }/
        text.should match /set { _data\[i\] = value; }/
      end

      it "sets the size of the array from configuration" do
        text.should match /public MyriadData\(\)/ # no args
        text.should match /_data = new UInt32\[16\];/
      end
    end
  end
end
