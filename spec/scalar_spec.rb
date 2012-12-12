describe Cauterize do
  before do
    reset_for_test
    flush_scalars
  end

  describe Scalar do
    describe :initialize do
      it "creates an scalar" do
        scalar(:foo).name.should == :foo
      end
    end

    describe :id do
      it { has_a_unique_id_for_each_instance(Scalar) }
    end
  end

  describe :scalar do
    it { creates_a_named_object(:scalar, Scalar) }
    it { retrieves_obj_with_identical_name(:scalar) }
    it { yields_the_object(:scalar) }
    it { adds_object_to_hash(:scalar, :scalars) }
  end

  describe :scalar! do
    it { creates_a_named_object(:scalar!, Scalar) }
    it { raises_exception_with_identical_name(:scalar!) }
    it { yields_the_object(:scalar!) }
    it { adds_object_to_hash(:scalar!, :scalars) }
  end

  describe :scalars do
    it { is_hash_of_created_objs(:scalar, :scalars) }
  end
end
