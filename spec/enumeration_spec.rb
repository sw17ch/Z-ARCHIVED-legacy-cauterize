module Cauterize
  describe Cauterize::EnumerationValue do
    describe :initialize do
      it "creates an EnumerationValue" do
        e = Cauterize::EnumerationValue.new(:foo, 1)
        e.name.should == :foo
        e.value.should == 1
      end
    end
  end

  describe Cauterize::Enumeration do
    describe :initialize do
      it "creates a new enumeration with the right name" do
        Cauterize::Enumeration.new(:foo).name.should == :foo
      end
    end

    describe :value do
      it "adds a new value to the enumeration" do
        enum = Cauterize.enumeration(:foo) do |e|
          e.value :a
          e.value :b
          e.value :c
          e.value :d
        end

        values = enum.values
        values.length.should == 4
        values.keys.should == [:a, :b, :c, :d]
        values.values.map(&:value).should == [0, 1, 2, 3]
      end

      it "accepts a fixed value" do
        enum = Cauterize.enumeration(:foo) do |e|
          e.value :a, 10
          e.value :b, 20
          e.value :c
        end

        values = enum.values
        values.keys.should == [:a, :b, :c]
        values.values.map(&:value).should == [10, 20, 21]
      end

      it "allows out-of-order values" do
        lambda {
          Cauterize.enumeration(:foo) do |e|
            e.value :a, 10
            e.value :b, 9
          end
        }.should_not raise_error
      end

      it "doesn't allow duplicate ids" do
        lambda {
          Cauterize.enumeration(:foo) do |e|
            e.value :a, 1
            e.value :b, 1
          end
        }.should raise_error /duplicate constant/
      end

      it "doesn't allow accidentally identical ids" do
        en = Cauterize.enumeration(:foo) do |e|
          e.value :a, 10
          e.value :b, 9
          e.value :c
        end

        en.values.values.map(&:value).should == [10,9,11]
      end

      it "errors on duplicate names" do
        lambda {
          Cauterize.enumeration(:foo) do |e|
            e.value :a
            e.value :a
          end
        }.should raise_error /duplicate name/
      end
    end

    describe :representation do
      it "chooses int8 when appropriate" do
        Cauterize.enumeration(:a) do |t|
          t.value :a, -128
        end.representation.name.should == :int8
        Cauterize.enumeration(:b) do |t|
          t.value :a, 127
        end.representation.name.should == :int8
      end

      it "chooses int16 when appropriate" do
        Cauterize.enumeration(:a) do |t|
          t.value :a, -32768
        end.representation.name.should == :int16
        Cauterize.enumeration(:b) do |t|
          t.value :a, 32767
        end.representation.name.should == :int16
        Cauterize.enumeration(:c) do |t|
          t.value :a, 300
        end.representation.name.should == :int16
      end

      it "chooses int32 when appropriate" do
        Cauterize.enumeration(:a) do |t|
          t.value :a, -2147483648
        end.representation.name.should == :int32
        Cauterize.enumeration(:b) do |t|
          t.value :a, 2147483647
        end.representation.name.should == :int32
      end

      it "chooses int64 when appropriate" do
        Cauterize.enumeration(:a) do |t|
          t.value :a, -9223372036854775808
        end.representation.name.should == :int64
        Cauterize.enumeration(:b) do |t|
          t.value :a, 9223372036854775807
        end.representation.name.should == :int64
      end
    end
  end

  describe :enumeration do
    it { creates_a_named_object(:enumeration, Enumeration) }
    it { retrieves_obj_with_identical_name(:enumeration) }
    it { yields_the_object(:enumeration) }
    it { adds_object_to_hash(:enumeration, Cauterize.enumerations) }
  end

  describe :enumeration! do
    it { creates_a_named_object(:enumeration!, Enumeration) }
    it { raises_exception_with_identical_name(:enumeration!) }
    it { yields_the_object(:enumeration!) }
    it { adds_object_to_hash(:enumeration!, Cauterize.enumerations) }
  end

  describe :enumerations do
    it { is_hash_of_created_objs(:enumeration, Cauterize.enumerations) }
  end
end
