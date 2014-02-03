module Cauterize
  describe :variable_array  do
    it { creates_a_named_object(:variable_array, VariableArray) }
    it { retrieves_obj_with_identical_name(:variable_array) }
    it { yields_the_object(:variable_array) }
    it { adds_object_to_hash(:variable_array, Cauterize.variable_arrays) }
  end

  describe :variable_array! do
    it { creates_a_named_object(:variable_array!, VariableArray) }
    it { raises_exception_with_identical_name(:variable_array!) }
    it { yields_the_object(:variable_array!) }
    it { adds_object_to_hash(:variable_array!, Cauterize.variable_arrays) }
  end

  describe :variable_arrays do
    it { is_hash_of_created_objs(:variable_array, Cauterize.variable_arrays) }
  end

  describe VariableArray do
    before { @a = VariableArray.new(:foo) }

    describe :initialize do
      it "creates a VariableArray" do
        @a.name.should == :foo
      end
    end

    describe :array_type do
      it "defines the type of the VariableArray" do
        Cauterize.scalar(:uint32_t)
        @a.array_type :uint32_t
        @a.instance_variable_get(:@array_type).name.should == :uint32_t
      end

      it "raises an error if type doesn't exist" do
        lambda {
          Cauterize.fixed_array(:fa) do |f|
            f.array_type :lol
          end
        }.should raise_error /lol does not correspond/
      end

      it "is the defined type if no argument is passed" do
        s = Cauterize.scalar(:uint32_t)
        @a.array_type :uint32_t
        @a.array_type.should be s
      end
    end

    describe :array_size do
      it "Defines the size of the FixedArray." do
        @a.array_size 46
        @a.instance_variable_get(:@array_size).should == 46
      end

      it "is the defined size if no argument is passed" do
        @a.array_size 46
        @a.array_size.should == 46
      end
    end

    describe :size_type do
      it "determines the type used to encode the array size" do
        @a.array_size 30000
        @a.size_type.name.should == :uint16

        @a.array_size 10
        @a.size_type.name.should == :uint8
      end
    end
  end
end
