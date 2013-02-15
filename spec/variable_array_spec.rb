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
      it "defines the type to use to encode the array size" do
        Cauterize.scalar(:uint16_t)
        @a.size_type :uint16_t
        @a.instance_variable_get(:@size_type).name.should == :uint16_t
      end

      it "raises an error if the type doesn't eixst" do
        lambda { @a.size_type :uintLOL_t }.should raise_error /does not correspond to a type/
      end

      it "raises an error if the type isn't an scalar" do
        Cauterize.scalar(:uint32_t)
        Cauterize.enumeration(:lol)
        lambda { @a.size_type :lol }.should raise_error /is not an scalar/
      end

      it "is the defined type if no argument is passed" do
        s = Cauterize.scalar(:uint32_t)
        @a.size_type :uint32_t
        @a.size_type.should be s
      end
    end
  end
end
