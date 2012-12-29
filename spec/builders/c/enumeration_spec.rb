describe Cauterize::Builders::C::Enumeration do
  let(:type_constructor) { lambda {|name| enumeration(name)}}

  it "scales its representation to the number of elements" do
    pending
  end

  it_behaves_like "a buildable"
  it_behaves_like "a sane buildable"
  include_examples "no struct"

  describe ".enum_defn" do
    let(:en) do
      _e = enumeration(:foo) do |e|
        e.value :aaa
        e.value :bbb
        e.value "QuickBrownFox".to_sym
      end

      f = default_formatter
      Builders.get(:c, _e).enum_defn(f)
      f.to_s
    end

    it "contains the enum name" do
      en.should match /enum foo/
    end

    it "contains an entry for each value" do
      en.should match /AAA = 0,/
      en.should match /BBB = 1,/
      en.should match /QUICK_BROWN_FOX = 2,/
      en.should match /};/
    end
  end
end
