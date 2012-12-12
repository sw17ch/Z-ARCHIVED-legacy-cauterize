describe Cauterize do
  before do
    reset_for_test
    flush_atoms
  end

  describe Atom do
    describe :initialize do
      it "creates an Atom" do
        Atom.new(:foo).name.should == :foo
      end
    end

    describe :id do
      it { has_a_unique_id_for_each_instance(Atom) }
    end
  end

  describe :atom do
    it { creates_a_named_object(:atom, Atom) }
    it { retrieves_obj_with_identical_name(:atom) }
    it { yields_the_object(:atom) }
    it { adds_object_to_hash(:atom, :atoms) }
  end

  describe :atom! do
    it { creates_a_named_object(:atom!, Atom) }
    it { raises_exception_with_identical_name(:atom!) }
    it { yields_the_object(:atom!) }
    it { adds_object_to_hash(:atom!, :atoms) }
  end

  describe :atoms do
    it { is_hash_of_created_objs(:atom, :atoms) }
  end
end
