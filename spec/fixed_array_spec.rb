module Cauterize
  describe :fixed_array  do
    it { creates_a_named_object(:fixed_array, FixedArray) }
    it { retrieves_obj_with_identical_name(:fixed_array) }
    it { yields_the_object(:fixed_array) }
    it { adds_object_to_hash(:fixed_array, Cauterize.fixed_arrays) }
  end

  describe :fixed_array! do
    it { creates_a_named_object(:fixed_array!, FixedArray) }
    it { raises_exception_with_identical_name(:variable_array!) }
    it { yields_the_object(:fixed_array!) }
    it { adds_object_to_hash(:fixed_array!, Cauterize.fixed_arrays) }
  end

  describe FixedArray do
    before { @a = Cauterize.fixed_array(:foo) }

    describe :initialize do
      it "Creates a fixed array." do
        @a.name.should == :foo
      end
    end

    it { can_be_documented(Cauterize::FixedArray) }

    describe :array_type do
      it "Defines the type of the FixedArray." do
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
  end
end
