describe Cauterize do
  before { reset_for_test }

  describe :fixed_array  do
    it { creates_a_named_object(:fixed_array, FixedArray) }
    it { retrieves_obj_with_identical_name(:fixed_array) }
    it { yields_the_object(:fixed_array) }
    it { adds_object_to_hash(:fixed_array, :fixed_arrays) }
  end

  describe :fixed_array! do
    it { creates_a_named_object(:fixed_array!, FixedArray) }
    it { raises_exception_with_identical_name(:variable_array!) }
    it { yields_the_object(:fixed_array!) }
    it { adds_object_to_hash(:fixed_array!, :fixed_arrays) }
  end

  describe FixedArray do
    before { @a = fixed_array(:foo) }

    describe :initialize do
      it "Creates a fixed array." do
        @a.name.should == :foo
        @a.id.should_not be_nil
      end
    end

    describe :array_type do
      it "Defines the type of the FixedArray." do
        atom(:uint32_t)
        @a.array_type :uint32_t
        @a.instance_variable_get(:@array_type).name.should == :uint32_t
      end

      it "raises an error if type doesn't exist" do
        lambda {
          fixed_array(:fa) do |f|
            f.array_type :lol
          end
        }.should raise_error /lol does not correspond/
      end
    end

    describe :array_size do
      it "Defines the size of the FixedArray." do
        @a.array_size 46
        @a.instance_variable_get(:@array_size).should == 46
      end
    end
  end
end