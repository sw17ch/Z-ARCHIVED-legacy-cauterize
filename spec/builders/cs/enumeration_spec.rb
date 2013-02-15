module Cauterize
  describe Cauterize::Builders::CS::Enumeration do
    describe ".enum_defn" do
      let(:en) do
        _e = Cauterize.enumeration(:foo) do |e|
          e.value :aaa
          e.value :bbb
          e.value "quick_brown_fox".to_sym
        end

        f = default_formatter
        Builders.get(:cs, _e).enum_defn(f)
        f.to_s
      end

      it "contains the enum name" do
        en.should match /public enum Foo/
      end

      it "contains an entry for each value" do
        en.should match /Aaa = 0,/
        en.should match /Bbb = 1,/
        en.should match /QuickBrownFox = 2,/
        en.should match /};/
      end
    end
  end
end

